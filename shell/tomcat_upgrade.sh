#!/bin/bash

#后端服务"chain-retail" "chain" "psm" "chain-visual" "chain-analysis-new" 、"chain-converage.war";且chain-converage.war只能在18.2单版本发布;在A版
apps_list=("chain-retail" "chain" "psm" "chain-visual" "chain-analysis-new")

select=$1
new_version=`echo $2 |tr '[A-Z]' '[a-z]'`


function usage(){
	echo -e "\033[31m 语法错误,请根据指定参数执行脚本  \033[0m"      ## 红色
	echo "Usage options:{ sh $0 {all|chain-retail|chain|psm|chain-visual|chain-analysis-new} {A|B} {stop|start|restart|auto} }"
	exit 2

}

function check_grammar(){
	var=` echo  "${apps_list[@]}" |xargs -n1 |grep -w $1$ -c `
	if [ $var -ne 1 ] && [ $1 != "all" ];then
		usage
	fi
	if [ $2 != "B" ] && [ $2 != "A" ];then
		usage
	fi
	if [ $3 != "stop" ] && [ $3 != "start" ] && [ $3 != "restart" ] && [ $3 != "auto" ];then
		usage
	fi
}

function stop_service(){
	pid=`ps -ef|grep $2/$1|grep -v grep |awk '{print $2}'`
	if [ -n $pid ] ;then
		kill -9 $pid
	fi
	echo  "service $1  is stopping"
}

function start_service(){
	cd /app/tomcat/$2/${1}01/bin/
	sh  /app/tomcat/$2/${1}01/bin/startup.sh 
	echo "service $1 is starting"

}

function deploy_webroot(){
	packet_dir=/app/tomcat/scriptdeploy/
	if [ ! -f ${packet_dir}${1}.war ];then
		echo -e "\033[31m packet is Not exist! 请上传指定目录$packet_dir后执行  \033[0m"      ## 红色
		exit 2
	fi
	if [ -d /app/tomcat/${2}/${1}01/webapps/ ];then
		cd /app/tomcat/${2}/${1}01/webapps/ && rm -rf *
		cp ${packet_dir}${1}.war  /app/tomcat/${2}/${1}01/webapps/
	fi

	echo "packe $1  is deploying"

}




if [ $# -ne 3 ];then
	usage
fi

check_grammar $1 $2 $3


if [ $1 == "all" ]; then
	if [ $3 == "stop" ];then 
		for service in ${#apps_list[@]} ;do
			stop_service $service $new_version
		done
	elif [ $3 == "start" ];then
		for service in ${#apps_list[@]} ;do
			start_service $service $new_version
		done
	elif [ $3 == "restart" ];then
		for service in ${#apps_list[@]} ;do
			stop_service $service $new_version
			start_service $service $new_version
		done
	elif [ $3 == "auto" ];then
		for service in ${#apps_list[@]} ;do
			stop_service $service $new_version
			deploy_webroot $service $new_version
			start_service $service $new_version
		done
	fi
else
	if [ $3 == "stop" ];then 
			stop_service $1 $new_version
	elif [ $3 == "start" ];then
			start_service $1 $new_version
	elif [ $3 == "restart" ];then
			stop_service $1 $new_version
			start_service $1 $new_version
	elif [ $3 == "auto" ];then
			stop_service $1 $new_version
			deploy_webroot $1 $new_version
			start_service $1 $new_version
	fi
fi

tail -100f /app/tomcat/${new_version}/${1}01/logs/catalina.out
