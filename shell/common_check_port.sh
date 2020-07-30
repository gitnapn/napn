#!/bin/bash
## 4G_checkport.sh
##检查4G前端 应用和端口状态

a_file="a_file"$(date +%s)
b_file="b_file"$(date +%s)


a_server=`ls -l /app/tomcat/a |grep ^d|grep 0[1-9]$|awk '{print $9}'|xargs `
b_server=`ls -l /app/tomcat/b |grep ^d|grep 0[1-9]$|awk '{print $9}'|xargs `

for app in ${a_server}
do
	app_conf="/app/tomcat/a/${app}/conf/server.xml"
	shutport=`grep "SHUTDOWN" ${app_conf}|grep "port\=\""|grep -o  "[0-9]\{5\}"`
	listenerport=`grep "protocol\=\"HTTP" ${app_conf}|grep Connector |grep "port\=\""|grep -o  "[0-9]\{5\}"`
	echo " A版本应用${app}节点${app}的HTTP端口为: ${listenerport} ; SHUTDOWN端口为: ${shutport}"
	echo " A版本应用${app}节点${app}的HTTP端口为: ${listenerport} ; SHUTDOWN端口为: ${shutport}"  >> /app/tomcat/${a_file}
done



for app in ${b_server}
do
	app_conf="/app/tomcat/b/${app}/conf/server.xml"
	shutport=`grep "SHUTDOWN" ${app_conf}|grep "port\=\""|grep -o  "[0-9]\{5\}"`
	listenerport=`grep "protocol\=\"HTTP" ${app_conf}|grep Connector |grep "port\=\""|grep -o  "[0-9]\{5\}"`
	echo " B版本应用${app}节点${app}的HTTP端口为: ${listenerport} ; SHUTDOWN端口为: ${shutport}"
	echo " B版本应用${app}节点${app}的HTTP端口为: ${listenerport} ; SHUTDOWN端口为: ${shutport}"  >> /app/tomcat/${b_file}
done

rm   /app/tomcat/${a_file}  /app/tomcat/${b_file}

