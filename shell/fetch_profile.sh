#!/bin/bash

function Usage(){
	echo "Usages: "
	echo "      sh $0 {4gfe|zdxs|qdmh|4gbe|dianqu|ess} {a|b} "
	exit 2
}

function fetch_file(){
/usr/bin/expect <<EOF
set timeout 10
spawn scp -r tomcat@${host_ip}:/app/tomcat/${version}/properties ${work_conf}/${system_name}/
expect {
"(yes/no)?" {send "yes\r";exp_continue}
"*assword:" {send "jt_4G_T135!\r";}
}
expect eof
EOF

}

systems=("4gfe" "zdxs" "qdmh" "4gbe" "dianqu" "ess")
ip_list=("10.128.97.233" "10.128.18.3" "10.128.12.40" "10.128.21.33" "10.128.97.244" "10.128.25.30")


work_conf=/app/IBM/wasdeploy/shell_xiaxh/tmp/$(date +%Y%m%d)

if [ ! -d ${work_conf} ];then
	mkdir -p ${work_conf}
fi

system_name=$1
version=`echo $2 |tr "A-Z" "a-z"`

if [ "$version" != "a" -a "$version" != "b" ];then
	Usage
fi


flag=`echo ${systems[@]}|xargs -n1|grep -w ${system_name} -c`

if [ $flag -eq 1 ];then
	mkdir -p ${work_conf}/${system_name}
	num_flag=`echo ${systems[@]}|xargs -n1|grep -w -n ${system_name}|awk -F ":" '{print $1}'`
	num=`expr ${num_flag} - 1`
	host_ip=${ip_list[num]}
	fetch_file
	if [ "${system_name}" == "4gfe" ];then
		echo "获取非特例省份(湖北:10.128.97.233)${version}版本配置"
		cp ${work_conf}/${system_name}/properties/common/MDA.xml ${work_conf}/${system_name}/MDA.xml_ah
		cp ${work_conf}/${system_name}/properties/common/MDA.xml ${work_conf}/${system_name}/MDA.xml_sc
		cp ${work_conf}/${system_name}/properties/common/MDA.xml ${work_conf}/${system_name}/MDA.xml_zj
		cp ${work_conf}/${system_name}/properties/common/MDA.xml ${work_conf}/${system_name}/MDA.xml_sx
                ah_num=`grep -w -n "DIS_ASSEMBLE_FLAG" ${work_conf}/${system_name}/MDA.xml_ah |awk -F ":" '{print $1}'`
                sc_num=`grep -w -n "ASYN_ADD_COMPLETE_SWITCH" ${work_conf}/${system_name}/MDA.xml_sc |awk -F ":" '{print $1}' `
                sx_num=`grep -w -n "STAFFCODE_AREAID_SWITCH" ${work_conf}/${system_name}/MDA.xml_sx |awk -F ":" '{print $1}' `
                zj_num=`grep -w -n "CHECK_CUST_TYPE"  ${work_conf}/${system_name}/MDA.xml_zj |awk -F ":" '{print $1}'`
                #sed -i "${ah_num}s#value=\"Y\"#value=\"N\"#" ${work_conf}/${system_name}/MDA.xml_ah
                #sed -i "${sc_num}s#value=\"Y\"#value=\"N\"#" ${work_conf}/${system_name}/MDA.xml_sc
                #sed -i "${sx_num}s#value=\"Y\"#value=\"N\"#" ${work_conf}/${system_name}/MDA.xml_sx 
                #sed -i "${zj_num}d" ${work_conf}/${system_name}/MDA.xml_zj
                #sed -i "${zj_num}i <const type=\"List\" name=\"CHECK_CUST_TYPE\" description=\"待收费状态购物车类型\"> [] </const> " ${work_conf}/${system_name}/MDA.xml_zj
		echo -e "\033[1;41;33m 特例省份配置需手动修改哦 \033[0m"
	elif [ "${system_name}" == "4gbe" ];then
		echo "获取4G后端10.128.21.33 ${1}版本配置"
		echo -e "\033[1;41;33m 删除特殊配置prvncCrmDataWeb_* \033[0m"
		rm -f ${work_conf}/${system_name}/properties/prvncCrmDataWeb_*
	else
		echo "无特殊情况"
	fi
else
	Usage
fi

echo "$(date +%Y-%m-%d" "%H:%M:%S) 采集完毕"


