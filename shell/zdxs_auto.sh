#!/bin/bash

function Usage(){
	echo "语法错误！请根据提示执行"
	echo "Usage: sh $0 {A|B} "
	exit 2
}

function profile(){
	if [ "$version" == "A" ];then
		properties="/app/tomcat/b/properties/*"
		zhuanyi='*'
		backup_profile=" ansible -i /etc/ansible/hosts_puppet_mvno $ip_group -m shell -a \"cd /app/tomcat/a/properties  && zip -r profile_backup-a.zip ${zhuanyi} \" "
		syn_profile="ansible -i /etc/ansible/hosts_puppet_mvno $ip_group -m shell -a \" \bin\cp -r ${properties} /app/tomcat/a/properties/ \" "
		echo $backup_profile
		echo $syn_profile
	else
		properties="/app/tomcat/a/properties/*"
		backup_profile=" ansible -i /etc/ansible/hosts_puppet_mvno $ip_group -m shell -a \"cd /app/tomcat/b/properties  && zip -r profile_backup-b.zip ${zhuanyi} \""
		syn_profile="ansible -i /etc/ansible/hosts_puppet_mvno $ip_group -m shell -a \" \bin\cp -r ${properties} /app/tomcat/b/properties/ \" "
		echo $backup_profile
		echo $syn_profile
	fi
}

function dialing_test(){
	dialing_cmd="ansible -i /etc/ansible/hosts_puppet_mvno $ip_group -m shell -a \"/app/tomcat/scriptdeploy/check_server.sh $version \" -f 30  -u tomcat -k "
	dialing_return="ansible -i /etc/ansible/hosts_puppet_mvno $ip_group -m shell -a \" cat /app/tomcat/scriptdeploy/check_logs2 \" -f 30  -u tomcat  -k"
	echo ${dialing_cmd}
	echo ${dialing_return}
}

function hd_dispatch(){
	for aps in ${war_name};
	do
		copy_cmd="ansible -i /etc/ansible/hosts_puppet_mvno   $ip_group -m copy -a \"src=${work_dir}/${aps} dest=/app/tomcat/scriptdeploy \" -f 30 -u tomcat -k  "
		if [ "$aps" == "chain-converge.war" ];then
			deploy_cmd="ansible -i /etc/ansible/hosts_puppet_mvno $ip_group -m shell -a \" /app/tomcat/scriptdeploy/operation_auto_war.sh ${aps/\.war/} A auto\" -f 30 -u tomcat -k"
			echo -e "\033[31m  "chain-converge.war 仅灰度环境 A版本可用" \033[0m"
		else
			deploy_cmd="ansible -i /etc/ansible/hosts_puppet_mvno $ip_group -m shell -a \" /app/tomcat/scriptdeploy/operation_auto_war.sh ${aps/\.war/} ${version} auto\" -f 30 -u tomcat -k"
		fi
		echo "灰度环境：开始对应用${aps}的发布"
		echo ${copy_cmd}
		echo ${deploy_cmd}
		echo "灰度环境：应用${aps}的发布完成"
		if [ -f  ${work_dir}/packetbackup/${aps} ];then
			echo "cp ${work_dir}/packetbackup/${aps}{,_old}"
			echo "/bin/mv ${work_dir}/${aps} ${work_dir}/packetbackup/"
		else
			echo "/bin/mv ${work_dir}/${aps} ${work_dir}/packetbackup/"
		fi
	done
}

function sc_dispatch(){
	war_name=`ls -l *war|awk '{print $9}'|grep -v converge`
	for aps in ${war_name};
	do
		copy_cmd="ansible -i /etc/ansible/hosts_puppet_mvno   $ip_group -m copy -a \"src=${work_dir}/${aps} dest=/app/tomcat/scriptdeploy \" -f 30 -u tomcat -k  "
		deploy_cmd="ansible -i /etc/ansible/hosts_puppet_mvno $ip_group -m shell -a \" /app/tomcat/scriptdeploy/operation_auto_war.sh ${aps/\.war/} ${version} auto \" -f 30  -u tomcat -k"
		echo "生产环境：开始对应用${aps}的发布"
		echo ${copy_cmd}
		echo ${deploy_cmd}
		echo "生产环境：应用${aps}的发布完成"
		if [ -f  ${work_dir}/packetbackup/${aps} ];then
			echo "cp ${work_dir}/packetbackup/${aps}{,_old}"
			echo "/bin/mv ${work_dir}/${aps} ${work_dir}/packetbackup/"
		else
			echo "/bin/mv ${work_dir}/${aps} ${work_dir}/packetbackup/"
		fi
	done
}


work_dir=$(pwd `dirname $0`)
version=`echo $1|tr [a-z] [A-Z]`

if [ `ls -l ${work_dir} |grep war -c` -eq 0 ];then
	echo "请先上传应用包文件到指定目录:${work_dir}"
	exit 2
else
	cd ${work_dir}
	war_name=`ls -l *war|awk '{print $9}'`
fi

while true
do
	if [ "$version" != "A" -a "${version}" != "B" ];then
		Usage
	fi
	read -p "请选择你要发布的环境:{sc:hd}" var
	flag=`echo $var|tr [A-Z] [a-z]`
	if [ "${flag}" != "sc" ] && [ "${flag}" != "hd" ];then
		echo "输入错误选项,请结合选项输入,请重新执行"
		continue
	elif [ "${flag}" == "sc" ];then
		echo "即将发布生产(SC),请稍侯..."
		ip_group=\"ZDXS:!10.128.18.2\"
		echo "################################################################"
		echo "################################################################"
		echo "###########            开始备份配置文件                #########"
		profile
		echo "###########生产环境配置文件profile备份完成;开始发布应用#########"
		sc_dispatch
		echo "###########     生产环境应用发布完成;开始拨测服务      #########"
		dialing_test
		echo "完成"
		echo "################################################################"
		echo "################################################################"
		break
	else
		echo "即将发布灰度(hd),请稍侯..."
		ip_group=\"10.128.18.2\"
		echo "################################################################"
		echo "################################################################"
		echo "###########            开始备份配置文件                #########"
		profile
		echo "###########灰度环境配置文件profile备份完成;开始发布应用#########"
		hd_dispatch
		echo "###########     灰度环境应用发布完成;开始拨测服务      #########"
		dialing_test
		echo "完成"
		echo "################################################################"
		echo "################################################################"
		break
	fi
done


