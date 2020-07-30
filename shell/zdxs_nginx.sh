#!/bin/bash

app_list=(chain-retail chain psm chain-visual chain-analysis-new chain-wechat)


function Usage(){

	echo " Usage:"
	echo " 	sh $0 # 检查nginx状态及应用版本 "
	echo " 	sh $0 nginx  [8101|8102|8201|8888|9999] [stop|start] # 修改nginx监听端口 "
	echo " 	sh $0 app  [all|chain-retail|chain|psm|chain-visual|chain-analysis-new|chain-wechat] [A,a|B,b] # 切换app版本 "
	exit 2
}

function nginx_status(){

flag=`ps -ef|grep nginx|grep master|grep -v grep -c`

if [ $flag -ne 1 ];then
	echo -e "\033[1;41;33m  Nginx is not running  \033[0m"
	exit 2
else
	echo "#################"
	echo " nginx is running"
	open_port=`grep -v ^# /app/nginx/conf/nginx.conf |grep "server.*conf"|grep -o "[0-9]\{4\}"`
	if [ -n "$open_port" ];then
		for port in $open_port
		do
			echo " $port is listening"
		done
	else
		echo -e "\033[1;41;33m  Nginx does not listen on any ports;Please check the configuration \033[0m"
	fi
fi

}

function service_version(){

	echo "#################"
	for app in ${app_list[*]}
	do
		route_file=/app/nginx/conf/router/${app}.router.conf
		version=`grep  $app  ${route_file}|grep -o _[a-b] |tr [a-z] [A-Z] `
		echo  " ${app}${version}"
	done

}

function change_ListenPort(){

	flag=`grep server${listen_port} /app/nginx/conf/nginx.conf`
	if [ -n "$flag" ];then
		if [ "$listen_status" == "start" ];then
			if [ ` echo ${flag}|grep -c ^# ` -ne 0 ];then
				line_num=`grep -n server${listen_port} /app/nginx/conf/nginx.conf|awk -F ":" '{print $1}' `
				explanatory=`echo $flag|grep -o "^\#*" `
				sed -i "${line_num}s/${explanatory}//" /app/nginx/conf/nginx.conf
				/app/nginx/nginx -s reload
				nginx_status
			else
				echo "#################"
				echo " ${listen_port} is already listening "
			fi
		elif [ "$listen_status" == "stop" ];then
			if [ ` echo ${flag}|grep -c ^# ` -eq 0 ];then
				sed -i "s/${flag}/#&/" /app/nginx/conf/nginx.conf
				/app/nginx/nginx -s reload
				nginx_status
			else
				nginx_status
				echo -e "\033[1;41;33m  No listening on ${listen_port} \033[0m"
			fi
		else
			Usage
		fi
	else
		echo -e "\033[1;41;33m nginx.conf配置文件中不存在该监听的端口哦！！！  \033[0m"
		Usage
	fi
}

function change_Version(){

	flag=` grep -o "${var_app_name}_[a-b]"  /app/nginx/conf/router/${var_app_name}.router.conf`
	sed -i "s/${flag}/${var_app_name}_${app_version}/" /app/nginx/conf/router/${var_app_name}.router.conf
}

if [ `ps -ef|grep nginx|grep master|grep -v grep -c` -ne 1 ];then
	echo -e "\033[1;41;33m  Nginx is not running \033[0m"
	exit 2
fi

if [ -n "$1" ];then
	if [ "$1" == "nginx" ];then
		listen_port=$2
		listen_status=$3
		change_ListenPort
	elif [ "$1" == "app" ];then
		app_name=$2
		app_version=` echo $3|tr [A-Z] [a-z] `
		if [ "$app_version" != "a" -a "$app_version" != "b" ];then
			echo -e "\033[1;41;33m 版本$app_version 不存在;小老弟！！！\033[0m"
			Usage
		fi
		if [ "$app_name" == "all" ];then
			for var_app_name in ${app_list[*]}
			do
				change_Version
			done
			/app/nginx/nginx -s reload
			service_version
		elif [ `echo ${app_list[*]}|xargs -n1|grep -w "${app_name}\$" -c` -eq 1 ];then
			var_app_name=$app_name
			change_Version
			/app/nginx/nginx -s reload
			service_version
		else
			echo -e "\033[1;41;33m  app_list 不存在该应用服务$app_name;请核对   \033[0m"
			Usage
		fi
	else
		echo  -e "\033[1;41;33m  Invalid parameter \033[0m"
		Usage
	fi
else
	nginx_status
	service_version
fi



