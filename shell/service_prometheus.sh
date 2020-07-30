#!/bin/bash

server_path=/app/tomcat/prometheus-2.14.0
node_path=/app/tomcat/node_exporter-0.18.1
server_log=/app/tomcat/prometheus/prometheus-2.14.0/logs/server_$(date +%Y%m%d%H%M%S).log
node_log=/app/tomcat/prometheus/node_exporter-0.18.1/logs/node_$(date +%Y%m%d%H%M%S).log
Usage(){

	echo "Usage: "
	echo "	   sh $0 server restart"
#	echo "	   sh $0 server {start|stop|restart}"
#	echo "	   sh $0 node {start|stop|restart}"
	exit 2
}

server_start(){
	 nohup /app/tomcat/prometheus/prometheus-2.14.0/prometheus --web.listen-address="0.0.0.0:20201" --storage.tsdb.path="/app/tomcat/prometheus/prometheus-2.14.0/data"  --storage.tsdb.retention.time=14d --web.enable-admin-api --web.enable-lifecycle --config.file="/app/tomcat/prometheus/prometheus-2.14.0/prometheus.yml"   > ${server_log} &
} 
server_stop(){
	ps -ef|grep prometheus|grep 20201|awk '{print $2}'|xargs -i  kill -9  {}
}

node_start(){
	nohup /app/tomcat/prometheus/node_exporter-0.18.1/node_exporter --web.listen-address=":20202"   > ${node_log} &
}
node_stop(){
	ps -ef|grep node_exporter|grep 20202 |awk '{print $2}'|xargs -i  kill -9  {}
}

case $1 in
"server")
	if [ "$2" == "stop" ];then
		server_stop
	elif [ "$2" == "start" ];then
		server_strat
	elif [ "$2" == "restart" ];then
		curl -X POST http://10.128.97.83:20201/-/reload
	fi
	;;
"node")
	if [ "$2" == "stop" ];then
		node_stop
	elif [ "$2" == "start" ];then
		node_strat
	elif [ "$2" == "restart"  ];then
		node_stop
		node_start
	fi
	;;
*)
	Usage
	;;
esac

