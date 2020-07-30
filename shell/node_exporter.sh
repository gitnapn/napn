#!/bin/bash

mkdir -p /app/tomcat/prometheus

if [ ! -f /app/tomcat/scriptdeploy/node_exporter.zip ];then
	echo "Installation package is missing"
	exit 2
fi

unzip -o /app/tomcat/scriptdeploy/node_exporter.zip -d /app/tomcat/prometheus

if [  -f /app/tomcat/prometheus/server_prometheus.sh ];then
	/bin/sh /app/tomcat/prometheus/server_prometheus.sh node restart
else
	echo " deployment failed"
	exit 2
fi

flag=`ps -ef|grep node_exporter|grep 20202 -c`

if [ $flag -eq 1 ];then
	echo "Deployment succeeded and started successfully."
else
	echo "Failed to start; please check."
	exit 2	
fi
