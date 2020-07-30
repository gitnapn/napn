#!/bin/bash

function Usage(){
	echo "Usages: "
	echo "      sh $0 {a|b} "
}


version=`echo $1 |tr "A-Z" "a-z"`

if [ "$version" != "a" -a "$version" != "b" ];then
	Usage
	exit 2
fi
config="/app/IBM/wasdeploy/shell_xiaxh/all_properties/4G_front/${version}/"

echo "开始采集10.128.103.77(河南X)tomcat配置"
/usr/bin/expect <<EOF
set timeout 10
spawn scp -r  tomcat@10.128.103.77:/app/tomcat/${version}/properties ${config}
expect {
"(yes/no)?" {send "yes\r";exp_continue}
"*assword:" {send "jt_4G_T135!\r";}
}
expect eof

EOF

echo "$(date +%Y-%m-%d" "%H:%M:%S) 4G配置文件采集完毕,收集路径:${config}"
