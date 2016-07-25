FROM ubuntu:14.04
MAINTAINER ATSD Developers <dev-atsd@axibase.com>
ENV version 13755
#metadata
LABEL com.axibase.vendor="Axibase Corporation" \
  com.axibase.product="Axibase Time Series Database" \
  com.axibase.code="ATSD" \
  com.axibase.revision="${version}"

#configure system
RUN locale-gen en_US.UTF-8 \
  && adduser --disabled-password --quiet --gecos "" axibase;

#apt-get jobs
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 26AEE425A57967CFB323846008796A6514F3CB79 \
  && echo "deb [arch=amd64] http://axibase.com/public/repository/deb/ ./" >> /etc/apt/sources.list \
  && apt-get update && apt-get install -y atsd=${version}; 

#set hbase distributed mode false
USER axibase
RUN sed -i '/.*hbase.cluster.distributed.*/{n;s/.*/   <value>false<\/value>/}' /opt/atsd/hbase/conf/hbase-site.xml


#comment out hadoop usage, stop checking hbase
RUN sed -i '52,55 s/^/#/' /opt/atsd/bin/atsd-all.sh && \
	sed -i '62,65 s/^/#/' /opt/atsd/bin/atsd-all.sh && \
	sed -i '289 s/^/#/' /opt/atsd/bin/atsd-hbase.sh && \
	sed -i '305,65 s/^/#/' /opt/atsd/bin/atsd-hbase.sh

#put script to docker
ADD hbase-site.xml /opt/atsd/hbase/conf/

#prepare database
RUN /opt/atsd/install_user.sh && /opt/atsd/bin/atsd-all.sh stop


#custom entrypoint to api-test reason
ADD entrypoint.sh /

#jmx, atsd(tcp), atsd(udp), pickle, http, https
EXPOSE 1099 8081 8082/udp 8084 8088 8443
VOLUME ["/opt/atsd"]
ENTRYPOINT ["/bin/bash","/entrypoint.sh"]

