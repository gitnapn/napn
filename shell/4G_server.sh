#!/bin/bash

version_a=("50002" "50006" "50020" "50021" "50022" "50017" "50018" "50019" "50014" "50015" "50016" "50011" "50012" "50013" "50025" "50026" "50027" "50028" "50029" "50030" "50029" "50030" "50031" "50009" "50023" "50024" "11051" "50010" "50005" "50035")
version_b=("60502" "60506" "60520" "60521" "60522" "60517" "60518" "60519" "60514" "60515" "60516" "60511" "60512" "60513" "60525" "60526" "60527" "60528" "60529" "60530" "60529" "60530" "60531" "60509" "60523" "60524" "11051" "60510" "60505" "60535")

app_list=("provPortal" "portalService" "SoWeb" "SoWeb" "SoWeb" "RuleManagerWeb" "RuleManagerWeb" "RuleManagerWeb" "RuleWeb" "RuleWeb" "RuleWeb" "BusinessDispatchWeb" "BusinessDispatchWeb" "BusinessDispatchWeb" "PrvncCrmExtrnlService" "PrvncCrmExtrnlService" "PrvncCrmInnerService" "PrvncCrmInnerService" "SRHttpServiceWeb" "SRHttpServiceWeb" "SRHttpServiceWeb" "SRHttpServiceWeb" "channelService" "smService" "LTE-CSB" "LTE-CSB" "listenerProcessor" "casw " "ltePad" "RestCrmExtrnlService")

dialing_url=("/provPortal/staff/setJavascriptDeveloperModel?code=DV82KN" "/portalService/or.sr" "/SoWeb/service/intf.prodInstService/queryProdAndOfferByConditions" "/SoWeb/service/intf.prodInstService/queryProdAndOfferByConditions" "/SoWeb/service/intf.prodInstService/queryProdAndOfferByConditions" "/RuleManagerWeb/service/so.rule.ruleSMO/check4GRuleSoPrepare" "/RuleManagerWeb/service/so.rule.ruleSMO/check4GRuleSoPrepare" "/RuleManagerWeb/service/so.rule.ruleSMO/check4GRuleSoPrepare" "/RuleWeb/service/so.rule.ruleSMO/check4GRuleSoPrepare" "/RuleWeb/service/so.rule.ruleSMO/check4GRuleSoPrepare" "/RuleWeb/service/so.rule.ruleSMO/check4GRuleSoPrepare" "/BusinessDispatchWeb/service/intf.businessDispatchService/listenForProvReport" "/BusinessDispatchWeb/service/intf.businessDispatchService/listenForProvReport" "/BusinessDispatchWeb/service/intf.businessDispatchService/listenForProvReport" "/PrvncCrmExtrnlService/ProvinceHttpService" "/PrvncCrmExtrnlService/ProvinceHttpService" "/PrvncCrmInnerService/service/agentNotifySevice" "/PrvncCrmInnerService/service/agentNotifySevice" "/SRHttpServiceWeb/sniffer.jsp?getDbStatus=y" "/SRHttpServiceWeb/sniffer.jsp?getDbStatus=y" "/SRHttpServiceWeb/service/VersionService/getVersion" "/SRHttpServiceWeb/service/VersionService/getVersion" "/channelService/service/interact/synStaffBean/qryChannelByRelaStaff" "/smService/sysManager/staffLogin" "/LTE-CSB/HttpDEPService" "/LTE-CSB/HttpDEPService" "/listenerProcessor/sniffer.jsp?getDbStatus=y" "/casw/ca/cert/noSignSeal4Pdf" "/ltePad/index.html" "/RestCrmExtrnlService/sniffer.jsp?getDbStatus=y")

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
			echo -e "\033[1;41;33m 铁汁,没找到这个目录:${deploy_path};请联系xiaxh@asiainfo.com  \033[0m "
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
		except_list=(`cat ${a_log} |awk -F '/' '{print $2}'|xargs`)
		except_port=(`cat ${a_log} |awk -F '/' '{print $1}'|xargs`)
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
					fi
					nohup sh /app/tomcat/a/${server}/bin/startup.sh >/dev/null &
					echo "A版本 ${server} 异常已处理 "
				fi
			done
		done
	fi

	Dialing_b
	if [ -f ${b_log} ];then
		echo "开始处理 B版本异常应用"
		except_list=(`cat ${b_log} |awk -F '/' '{print $2}'|xargs`)
		except_port=(`cat ${b_log} |awk -F '/' '{print $1}'|xargs`)
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
	if [ $flag_app -ge 1 -a  $flag_version -ge 1 ];then
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

