#!/bin/bash

tmp_dir="/app/IBM/wasdeploy/shell_xiaxh/tmp/$(date +%Y%m%d)"
if [ ! -d  $tmp_dir ];then
	mkdir -p $tmp_dir

fi
rm -f  $tmp_dir/*dail_nginx.log 

port_list=(8100 8101 8102 8888 9999 8201)
mgr_port_list=(8101 8102)

crm_list=("ltePortal" "BusinessDispatchWeb" "casw" "channelService" "LTE-CSB" "portalService" "provPortal" "PrvncCrmExtrnlService" "PrvncCrmInnerService" "pubPortal" "RuleManagerWeb" "RuleWeb" "smService" "SoWeb" "SRHttpServiceWeb" "ltePad" "RestCrmExtrnlService")

dianqu_list=("ltePortal" "appPortal" "ltePad" "pubPortal" "provPortal" "portalService" "channelService" "RestCrmExtrnlService" "PrvncCrmExtrnlService" "PrvncCrmInnerService" "RuleManagerWeb" "RuleWeb" "smService" "SoWeb" "SRHttpServiceWeb" "casw" "ecs_appmanager" "ecs_appmanager_config" "LTE-CSB")

mgr_list=("channelWeb" "channel-manager-web" "SupportToolWeb" "offerManagerWeb" "ppm" "opcNew" "ppmintf" "saleResourceWeb" "smWeb" "smLtePortal" "LogServer")


function Usage(){
	echo  -e "\033[1;41;33m  Invalid parameter \033[0m"
	echo " Usage:"
	echo " 	sh $0 [crm|dq|mgr|all] # crm:4G前端nginx状态 dq:电渠nginx状态 mgr:4g后端nginx状态;all:以上nginx 状态。"
	exit 2	

}

function crm_nginx(){

	#拨测4g前端的机器
	ansible 'tomcat_all' -i "/etc/ansible/new_hosts" -m shell -a "/app/nginx/script/nginx.sh" -f 50 -u nginx -k   >> $tmp_dir/4g-dail_nginx.log
	#拨测docker机器版本
	ansible 'docker-tianjin:docker-neimenggu:docker-heilongjiang:docker-hainan' -i "/etc/ansible/docker_4G_hosts" -m shell -a "docker exec nginx /bin/bash /app/nginx/script/nginx.sh " -f 50 >> $tmp_dir/4g-dail_nginx.log
	echo -e "\033[1;41;33m 4g前端监听端口情况如下  \033[0m"
	for((i=0;i<${#port_list[@]};i++))
	do
		A_num=`grep ${port_list[i]}"_A"  $tmp_dir/4g-dail_nginx.log -c `
		B_num=`grep ${port_list[i]}"_B"  $tmp_dir/4g-dail_nginx.log -c `
		echo "${port_list[i]}_A:${A_num}"
		echo "${port_list[i]}_B:${B_num}"
	done
	
	echo -e "\033[1;41;33m 4g前端应用版本情况如下  \033[0m"
	for((j=0;j<${#crm_list[@]};j++))
	do 
		A_num=`grep ${crm_list[j]}"_A"  $tmp_dir/4g-dail_nginx.log -c `
		B_num=`grep ${crm_list[j]}"_B"  $tmp_dir/4g-dail_nginx.log -c `		
		echo "${crm_list[j]}_A:${A_num}"
		echo "${crm_list[j]}_B:${B_num}"	
	done

}

function dianqu_nginx(){

	#拨测电渠机器
	ansible 'DIANQU' -i "/etc/ansible/hosts_puppet_mvno" -m shell -a "/app/nginx/script/nginx.sh" -f 30 -u nginx -k >> $tmp_dir/dianqu-dail_nginx.log

	echo -e "\033[1;41;33m 4g前端监听端口情况如下  \033[0m"
	for((i=0;i<${#port_list[@]};i++))
	do
		A_num=`grep ${port_list[i]}"_A"  $tmp_dir/dianqu-dail_nginx.log -c `
		B_num=`grep ${port_list[i]}"_B"  $tmp_dir/dianqu-dail_nginx.log -c `
		echo "${port_list[i]}_A:${A_num}"
		echo "${port_list[i]}_B:${B_num}"
	done
	
	echo -e "\033[1;41;33m 电渠应用版本情况如下  \033[0m"
	for((j=0;j<${#dianqu_list[@]};j++))
	do 
		A_num=`grep ${dianqu_list[j]}"_A"  $tmp_dir/dianqu-dail_nginx.log -c `
		B_num=`grep ${dianqu_list[j]}"_B"  $tmp_dir/dianqu-dail_nginx.log -c `		
		echo "${dianqu_list[j]}_A:${A_num}"
		echo "${dianqu_list[j]}_B:${B_num}"	
	done

}

function mgr_nginx(){

	#拨测4g后端机器
	ansible 'MGR01:MGR02' -i "/etc/ansible/hosts_puppet_mvno" -m shell -a "/app/nginx/script/nginx.sh" -f 30 -u nginx -k >>  $tmp_dir/mgr-dail_nginx.log

	echo -e "\033[1;41;33m 4g前端监听端口情况如下  \033[0m"
	for((i=0;i<${#mgr_port_list[@]};i++))
	do
		num=`grep ${mgr_port_list[i]}"_R"  $tmp_dir/mgr-dail_nginx.log -c `
		echo "${port_list[i]}_R:${num}"
	done
	
	echo -e "\033[1;41;33m 4g后端应用版本情况如下  \033[0m"
	for((j=0;j<${#mgr_list[@]};j++))
	do 
		A_num=`grep ${mgr_list[j]}"_A"  $tmp_dir/mgr-dail_nginx.log -c `
		B_num=`grep ${mgr_list[j]}"_B"  $tmp_dir/mgr-dail_nginx.log -c `		
		echo "${mgr_list[j]}_A:${A_num}"
		echo "${mgr_list[j]}_B:${B_num}"	
	done

}



case $1 in
	"crm")
		crm_nginx
		;;
	"dq")
		dianqu_nginx
		;;
	"mgr")
		mgr_nginx
		;;
	"all")
		crm_nginx
		echo "#####################################"
		dianqu_nginx
		echo "#####################################"
		mgr_nginx
		echo "#####################################"
		;;
	*)
		Usage
		;;
esac



