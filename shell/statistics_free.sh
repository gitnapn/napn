#!/bin/bash

function expr_s(){
	rate=`expr $var_used \* 100 / $var_total`
	date +%Y-%m-%d" "%H:%M:%S
	top -n 1 -b |sed -n 3p|awk -F, '{print $1,$2," ",$4}'
	load=`uptime|awk -F "," '{print $4,$5,$6}'`
	echo ${load}
	echo "Mem(m):Total:${var_total},Used:${var_used}, Rate:${rate}% "
	df -h -P|grep -w "/app"|awk '{print $NF," ",$2," ",$3," ",$4," ",$5}'
}

if [ `uname -r |grep el7 -c ` -eq 1 ];then
	var_total=`free -m|awk '/Mem:/ {print $2} '`
	var_used=`free -m|awk '/Mem:/ {print $3} '`
	expr_s
elif [ `uname -r |grep el6 -c ` -eq 1 ];then
	var_total=`free -m|awk '/Mem:/ {print $2} '`
	#var_used=`free -m|awk '/Mem:/ {print $3} '` 
	var_used=`free -m|awk ' /buffers\/cache/ {print $3} '`
	expr_s
else
	echo "仅适应centos6、7"
	exit 2
fi

