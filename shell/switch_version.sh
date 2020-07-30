#!/bin/bash

#后端服务"chain-retail" "chain" "psm" "chain-visual" "chain-analysis-new" 、"chain-converage.war";且chain-converage.war只能在18.2单版本发布;在A版
apps_list=("chain-retail" "chain" "psm" "chain-visual" "chain-analysis-new")

select=$1
new_version=`echo $2 |tr '[A-Z]' '[a-z]'`

function usage(){
	echo -e "\033[31m 语法错误,请根据指定参数执行脚本  \033[0m"      ## 红色
	echo "Usage options:{ sh $0 {all|chain-retail|chain|psm|chain-visual|chain-analysis-new} {A|B} }"
	exit 2

}

function check_grammar(){
	var=` echo  "${apps_list[@]}" |xargs -n1 |grep -w $1$ -c `
	if [ $var -ne 1 ] && [ $1 != "all" ];then
		usage
	fi
	if [ $2 != "B" ] && [ $2 != "A" ];then
		usage
	fi
}


function switch_all(){
	echo "开始切换 $1"
	for var in ${apps_list[@]}; do
		old_version=`grep default  /app/nginx/conf/router/${var}.router.conf |awk '{print $2}'`
		sed -i "s#${old_version}#${var}_${new_version}#" /app/nginx/conf/router/${var}.router.conf
		flag=`grep default  /app/nginx/conf/router/${var}.router.conf |awk '{print $2}'|awk -F '_' '{print $2}'`
		if [ $flag != $new_version ] ;then
			echo -e "\033[31m ${var}切换版本$2失败;请核查 \033[0m"      ## 红色
			exit 2
		else
			echo -e "\033[32m ${var}完成版本的切换为: $2 版本 \033[0m"      ## 绿色
		fi
	done
	echo "all 切换完毕"
}

function switch_one(){
	echo "开始切换 $1"
	old_version=`grep default  /app/nginx/conf/router/$1.router.conf |awk '{print $2}'`
	sed -i "s#${old_version}#$1_${new_version}#g" /app/nginx/conf/router/$1.router.conf
	flag=`grep default  /app/nginx/conf/router/$1.router.conf |awk '{print $2}'|awk -F '_' '{print $2}'`
	if [ $flag != $new_version ] ;then
		echo -e "\033[31m $1切换版本$2失败;请核查 \033[0m"      ## 红色
		exit 2
	else
		echo -e "\033[32m $1完成版本的切换为: $2 版本 \033[0m"      ## 绿色
	fi
	echo "$1 切换完毕"
}


if [ $# -ne 2 ];then
	usage
fi

check_grammar $1 $2

if [ $1 != "all" ];then
	switch_one $1 $2
else
	switch_all $1 $2
fi


