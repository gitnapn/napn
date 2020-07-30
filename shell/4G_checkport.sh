#!/bin/bash

##检查4G前端 应用和端口状态

app_list=("unifyLogin" "ltePortal" "ltePad" "portalService" "smService" "ca-service-web" "BusinessDispatchWeb" "RuleWeb" "RuleManagerWeb" "SoWeb" "LTE-CSB" "PrvncCrmExtrnlService" "PrvncCrmInnerService" "SRHttpServiceWeb" "channelService" "RestCrmExtrnlService" "listenerProcessor")

for app in ${app_list[@]}
do
	appname=`ls -rtl /app/tomcat/a|grep ^d|grep ${app}0|awk '{print $9}'|xargs echo `
	if [ -n "$appname" ];then 
		for var in $appname
		do
			app_conf="/app/tomcat/a/${var}/conf/server.xml"
			shutport=`grep "SHUTDOWN" ${app_conf}|grep "port\=\""|grep -o  "[0-9]\{5\}"`
			listenerport=`grep "protocol\=\"HTTP" ${app_conf}|grep Connector |grep "port\=\""|grep -o  "[0-9]\{5\}"`
			echo " A版本应用${app}节点${var}的HTTP端口为: ${listenerport} ; SHUTDOWN端口为: ${shutport}"
		done
	else
		echo -e "\033[1;41;33m A版本没有该服务  ${app} \033[0m" 
	fi	
done

echo "#############分割线#################"

for app in ${app_list[@]}
do
	appname=`ls -rtl /app/tomcat/b|grep ^d|grep ${app}0|awk '{print $9}'|xargs echo `
	if [ -n "$appname" ];then 
		for var in $appname
		do
			app_conf="/app/tomcat/b/${var}/conf/server.xml"
			shutport=`grep "SHUTDOWN" ${app_conf}|grep "port\=\""|grep -o  "[0-9]\{5\}"`
			listenerport=`grep "protocol\=\"HTTP" ${app_conf}|grep Connector |grep "port\=\""|grep -o  "[0-9]\{5\}"`
			echo " B版本应用${app}节点${var}的HTTP端口为: ${listenerport} ; SHUTDOWN端口为: ${shutport}"
		done
	else
		echo -e "\033[1;41;33m B版本没有该服务  ${app} \033[0m" 
	fi	
done

echo "主机$(hostname -I )检测完毕"

