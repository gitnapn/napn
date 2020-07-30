#!/bin/bash

app_name=("engine-openapi" "engine-service" "inst-service" "order-service" "rule-service" "sr-card-service" "sr-inst-service" "sr-pn-service" "spec-service" "timetask" "nbs-service" "sr-public-service")

war_name=$1
version=`echo ${2} | tr [a-z] [A-Z]`
label="V"$(date +%Y%m%d%H%M)

function Usage(){

	echo "Usage:"
	echo "sh  $0 {engine-openapi|engine-service|inst-service|order-service|rule-service|sr-card-service|sr-inst-service|sr-pn-service|spec-service|timetask|nbs-service|sr-public-service} {A|B}"
	exit 2
}

function docker_bulid(){
	if [ "${war_name}" == "nbs-service" ];then
			war_rename="nbs"
	else
		war_rename=$war_name
	fi
	echo " ansible-playbook /app/IBM/wasdeploy/shell_xiaxh/hlj_dockerbulid.yml -i /etc/ansible/bss3.0/docker/host_docker  --extra-vars "war_rename=${war_rename} war_name=${war_name} range=${range} label=${label} " "
}


function docker_release(){

	echo " ansible-playbook /app/IBM/wasdeploy/shell_xiaxh/hlj_release.yml -i /etc/ansible/bss3.0/docker/host_docker  --extra-vars "host_group=${ip} version=${back_version} label=${label} war_name=${war_name}" "
}

case ${war_name} in
  sr-card-service|sr-inst-service|sr-pn-service|spec-service)
  range=sr
  ip="10.130.155.24:10.130.155.25"
  ;;
  nbs-service|timetask|sr-public-service)
  range=com-all
  ip="10.130.155.22:10.130.155.23"
  ;;
  engine-openapi|engine-service|inst-service|rule-service|order-service)
  range=so
  ip="10.130.155.26:10.130.155.27:10.130.155.28:10.130.155.29"
  ;;
  *)
  Usage
  ;;
esac

if [ -z "${version}" ];then
	Usage
fi

docker_bulid

if [ "${war_name}" == "engine-openapi" ];then
	app_name="engine-openapi-service"
else
	app_name=$war_name
fi
if [ "${range}" != "com-all" ];then
	use_version=`curl http://10.130.154.44:8102/${app_name}/actuator/info |awk -F ',' '{print $4}'|awk -F '"' '{ print $4}'`

	if [ "${use_version}" == "A" ];then
		back_version="B"
	elif  [ "${use_version}" == "B" ];then
		back_version="A"
	else
		echo "铁铁！在用版本标志有误;退出发布！！！"
		exit 2
	fi
	if [ "${version}" != "${back_version}" ];then
		echo "铁铁,你输入的备用版本号与系统获取的不一致哦！！${version}是在用版本哦 "
		exit 2
	fi
else
	back_version=${version}
fi

docker_release


