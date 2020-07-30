#!/bin/bash

function Usage(){
	echo "Usages: "
	echo "      sh $0 {a|b} "
}

work_conf=/app/IBM/wasdeploy/shell_xiaxh/tmp/$(date +%Y%m%d)
#work_conf=/app/IBM/wasdeploy/shell_xiaxh/tmp/$(date +%s)

if [ ! -d ${work_conf} ];then
	mkdir -p ${work_conf} 
fi

version=`echo $1 |tr "A-Z" "a-z"`

if [ "$version" != "a" -a "$version" != "b" ];then
	Usage
	exit 2
fi

echo "开始获取非特例省份(湖北:10.128.97.233)${1}版本配置"
/usr/bin/expect <<EOF
set timeout 10
spawn scp -r tomcat@10.128.97.233:/app/tomcat/${version}/properties ${work_conf}/ 
expect {
"(yes/no)?" {send "yes\r";exp_continue}
"*assword:" {send "jt_4G_T135!\r";}
}
expect eof
EOF

cp ${work_conf}/properties/common/MDA.xml ${work_conf}/MDA.xml_ah
cp ${work_conf}/properties/common/MDA.xml ${work_conf}/MDA.xml_sc
cp ${work_conf}/properties/common/MDA.xml ${work_conf}/MDA.xml_zj
cp ${work_conf}/properties/common/MDA.xml ${work_conf}/MDA.xml_sx

echo "$(date +%Y-%m-%d" "%H:%M:%S) 采集完毕"
echo -e "\033[1;41;33m 特例省份配置需手动修改哦 \033[0m"  
