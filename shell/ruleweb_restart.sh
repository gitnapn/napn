#!/bin/bash

sh /app/tomcat/scriptdeploy/check_server.sh B

sleep 3


flag=`cat /app/tomcat/scriptdeploy/check_logs2` 
if [ -n "$flag" ];then
	echo "需执行重启"
	nohup /app/tomcat/scriptdeploy/tomat_operation_check_port.sh /app/tomcat/scriptdeploy/check_logs2 kill &
	sleep 5
	nohup /app/tomcat/scriptdeploy/tomat_operation_check_port.sh /app/tomcat/scriptdeploy/check_logs2 server &
else
	echo "程序正常"
fi 
