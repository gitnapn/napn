#!/bin/bash

version_a=('20101' '20201' '20301' '20401' '20601' '20701')
version_b=('20151' '20251' '20351' '20451' '20651' '20751')

app_list=('chain-retail' 'chain' 'psm' 'chain-visual' 'chain-analysis-new' 'chain-wechat')

dialing_url=("/chain/index.jsp" "/chain-retail/index.jsp" "/psm/login.jsp" "/chain-wechat/index.jsp" "/chain-visual/index.jsp" "/chain-analysis-new/index.jsp")

workdir=`pwd $(dirname $0)`

a_log=${workdir}"/a_log"$(date +%s)
b_log=${workdir}"/b_log"$(date +%s)


app_name=${1}
app_version=`echo ${2}|tr "A-Z" "a-z"`



function Usage(){

	echo  -e "\033[1;41;33m  Invalid parameter \033[0m"
	echo " Usage:"
	echo " 	sh $0 # 检查service状态 "
	echo " 	sh $0 [all|chain-retail|chain|psm|chain-visual|chain-analysis-new|chain-wechat] [A,a|B,b] [stop|start|restart|deploy] # 切换app版本 "
	exit 2
}

function  Dialing_a(){

	for ((i=0;i<${#dialing_url[@]};i++ ))
	do
		http_code=`curl -s -m 10 -o /dev/null --connect-timeout 5 -w "%{http_code}\n"  "http://127.0.0.1:"${version_a[i]}${dialing_url[i]}`
		if [ "${http_code}" != "200"  ];then
			echo "${version_a[i]}${dialing_url[i]} is not ok !" >> ${a_log}
		fi
	done
}

function  Dialing_b(){

	for ((i=0;i<${#dialing_url[@]};i++ ))
	do
		http_code=`curl -s -m 10 -o /dev/null --connect-timeout 5 -w "%{http_code}\n"  "http://127.0.0.1:"${version_b[i]}${dialing_url[i]}`
		if [ "${http_code}" != "200"  ];then
			echo "${version_b[i]}${dialing_url[i]} is not ok !"  >> ${b_log}
		fi
	done
}

function Dialing(){

	echo "主机$(hostname -i )情况如下:"
	Dialing_a
	if [ ! -f ${a_log} ];then
		echo "A版本服务正常"
	else
		echo -e "\033[1;41;33m A版本异常如下: \033[0m "
		cat ${a_log}
		rm -f ${a_log}
	fi

	echo "##################"
	Dialing_b
	if [ ! -f ${b_log} ];then
		echo "B版本服务正常"
	else
		echo -e "\033[1;41;33m B版本异常如下: \033[0m "
		cat ${b_log}
		rm -f ${b_log}
	fi
}


function service_stop(){

	flag=`ps -ef|grep ${app_version}/${app_name}0|grep java|awk '{print $2}'|xargs echo `
	if [ -n "${flag}" ];then
		kill -9 $flag
		echo "${app_version}版本服务${app_name} is stoped"
	else
		echo -e "\033[1;41;33m ${app_version}版本服务${app_name} is not running \033[0m "
	fi

}


function service_start(){

	for server in `ls -rlt /app/tomcat/${app_version}/ |grep ^d |grep ${app_name}0|awk '{print $9}'`
	do
		flag=`ps -ef|grep ${app_version}/${server}|grep java|awk '{print $2}'|xargs echo`
		if [ -z "${flag}" ];then
			server_bin="/app/tomcat/${app_version}/${server}/bin/"
			nohup sh  ${server_bin}"startup.sh"  > /dev/null  &
			echo "${app_version}版本服务${server} is  startover"
		else
			echo " ${app_version}版本服务${server} is already running"
		fi
	done

}

function service_restart(){

	service_stop
	sleep 1
	service_start

}


function deploy(){

	service_stop
	for server in `ls -rlt /app/tomcat/${app_version}/ |grep ^d |grep ${app_name}0|awk '{print $9}'`
	do
		deploy_path="/app/tomcat/${app_version}/${server}/webapps"
		if [ -d "${deploy_path}" ];then
			rm -rf ${deploy_path}/*
			cp /app/tomcat/scriptdeploy/${app_name}.war  ${deploy_path}
		else
			echo -e "\033[1;41;33m 铁子,没找到这个目录:${deploy_path};请联系xiaxh@asiainfo.com  \033[0m "
			exit 2
		fi
	done
	service_start
	echo "${app_version}版本服务${app_name} release completed "
}

function Handle(){

	Dialing_a
	if [ -f ${a_log} ];then
		echo "开始处理 A版本异常应用"
		except_list=`cat ${a_log} |awk -F '/' '{print $2}'|xargs`
		except_port=`cat ${a_log} |awk -F '/' '{print $1}'|xargs`
		for (( i=0;i<${#except_list[@]};i++))
		do
			port=${except_port[i]}
			var=${except_list[i]}			
			for server in `ls -rlt /app/tomcat/a/ |grep ^d |grep "${var}0"|awk '{print $9}'`
			do
				if [ `grep "${port}" /app/tomcat/a/${server}/conf/server.xml -c ` -eq 1 ];then
					flag=`ps -ef|grep a/${server}|grep java|awk '{print $2}'|xargs echo `
					if [ -n "$flag" ];then
						kill -9 $flag
						nohup sh /app/tomcat/a/${server}/bin/startup.sh >/dev/null &
					fi
					echo "A版本 ${server} 异常已处理 "
				fi
			done
		done
	fi

	Dialing_b
	if [ -f ${b_log} ];then
		echo "开始处理 B版本异常应用"
		except_list=`cat ${b_log} |awk -F '/' '{print $2}'|xargs`
		except_port=`cat ${b_log} |awk -F '/' '{print $1}'|xargs`
		for (( i=0;i<${#except_list[@]};i++))
		do
			port=${except_port[i]}
			var=${except_list[i]}
			for server in `ls -rlt /app/tomcat/b/ |grep ^d |grep "${var}0"|awk '{print $9}'`
			do
				if [ `grep "${port}" /app/tomcat/b/${server}/conf/server.xml -c ` -eq 1 ];then
					flag=`ps -ef|grep b/${server}|grep java|awk '{print $2}'|xargs echo `
					if [ -n "$flag" ];then
						kill -9 $flag
					fi
					nohup sh /app/tomcat/b/${server}/bin/startup.sh >/dev/null &
					echo "B版本 ${server} 异常已处理 "
				fi
			done
		done
	fi
	if [ ! -f ${a_log} -a ! -f ${b_log} ] ;then
		echo "A、B 版本都没有异常哦! nice "
	fi
	rm -f ${b_log} ${a_log}
	exit 2
}




if [ -n "$app_name" ];then

	if [ "$app_name" == "handle"  ] ;then
		Handle
	fi
	flag_app=`echo "${app_list[@]} all" |xargs -n 1|grep -w "${app_name}\$" -c `
	flag_version=`echo ${app_version}|grep "[a-b]" -c`
	if [ $flag_app -eq 1 -a  $flag_version -eq 1 ];then
		case $3 in
			"stop")
				if [ "$app_name" != "all" ];then
					service_stop
				else
					for var in ${app_list[@]}
					do
						app_name=${var}
						service_stop
					done
				fi
				;;
			"start")
				if [ "$app_name" != "all" ];then
					service_start
				else
					for var in ${app_list[@]}
					do
						app_name=${var}
						service_start
					done
				fi
				;;
			"restart")
				if [ "$app_name" != "all" ];then
					service_restart
				else
					for var in ${app_list[@]}
					do
						app_name=${var}
						service_restart
					done
				fi
				;;
			"deploy")
				deploy
				;;
			*)
				Usage
				;;
		esac
	else
		Usage
	fi
else
	Dialing
fi

