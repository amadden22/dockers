#!/bin/sh
echo "Executing restart script at `date`"
name="GREGORY_atsd-api-test"
login="admin"
password="123456"
httpPort="33007"
tcpPort="33009"

volume=$(docker inspect --format='{{range .Mounts}}{{.Name}}{{end}}' $name)
echo "remove container:"
docker rm -f $name
echo "remove associated volume:"
docker volume rm $volume

echo "starting new container..."
docker run -d -p $httpPort:8088 -p $tcpPort:8081 --name="$name" -e axiname="$login" -e axipass="$password" axibase/atsd:api-test
while ! curl hbs.axibase.com:$httpPort >/dev/null 2>&1; do echo "waiting to start $name server ..."; sleep 3; done
echo "Executin restart script at `date`"

