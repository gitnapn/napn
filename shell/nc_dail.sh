#!/bin/bash

src=("10.128.21.33" "10.128.25.22" "10.128.97.33" "10.128.98.40" "10.128.103.55" "10.128.104.2")
dest=("136.64.70.226" "136.64.70.88" "136.64.70.89")
port=("9500" "9600" "9700" "9800")



for((i=0;i<${#src[@]};i++))
do
	for((j=0;j<${#dest[@]};j++))
	do 
		for((k=0;k<${#port[@]};k++))
		do
			ip_src=${src[${i}]}
			ip_dest=${dest[${j}]}
			dest_port=${port[${k}]}
			echo "${ip_src}网段 拨测如下:"
/usr/bin/expect <<EOF
set timeout 10
spawn ssh tomcat@${ip_src} "nc -v -z ${ip_dest} ${dest_port}"
expect {
"(yes/no)?" {send "yes\r";exp_continue}
"*assword:" {send "jt_4G_T135!\r";}
}
expect eof

EOF
		done	
	done 
done
	
	
	
