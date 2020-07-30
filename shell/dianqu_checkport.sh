#!/bin/bash
## 4G_checkport.sh 
##检查4G前端 应用和端口状态

a_file="a_file"$(date +%s)
b_file="b_file"$(date +%s)


app_list=("unifyLogin" "pubPortal" "appPortal" "portalService" "smService" "ca-service-web" "BusinessDispatchWeb" "RuleWeb" "RuleManagerWeb" "SoWeb" "LTE-CSB" "PrvncCrmExtrnlService" "PrvncCrmInnerService" "SRHttpServiceWeb" "channelService" "ecs_appmanager_config" "ecs_appmanager" "ltePortal" "RestCrmExtrnlService" "listenerProcessor" "ltePad")

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
			echo " A版本应用${app}节点${var}的HTTP端口为: ${listenerport} ; SHUTDOWN端口为: ${shutport}"  >> /app/tomcat/${a_file}
		done
	else
		echo -e "\033[1;41;33m A版本没有该服务  ${app} \033[0m" 
	fi	
done

flag=`cat /app/tomcat/${a_file}|grep [0-9] -c`
real=`ls -rtl /app/tomcat/a|grep ^d|grep -v properties -c `

if [ "${flag}" -ne "${real}" ];then
	echo -e "\033[1;41;33m 请人工核查未记录的A版本应用   \033[0m" 

fi


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
			echo " B版本应用${app}节点${var}的HTTP端口为: ${listenerport} ; SHUTDOWN端口为: ${shutport}"  >> /app/tomcat/${b_file}
		done
	else
		echo -e "\033[1;41;33m B版本没有该服务  ${app} \033[0m" 
	fi	
done

echo "主机$(hostname -I )检测完毕"

flag=`cat /app/tomcat/${b_file}|grep [0-9] -c`
real=`ls -rtl /app/tomcat/b|grep ^d|grep -v properties -c `

if [ "${flag}" -ne "${real}" ];then
	echo -e "\033[1;41;33m 请人工核查未记录的B版本应用   \033[0m" 

fi

rm   /app/tomcat/${a_file}  /app/tomcat/${b_file} 

