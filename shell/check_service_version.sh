#!/bin/bash
#nginx代理端口8104
nginx_port="8104"
#后端服务"chain-retail" "chain" "psm" "chain-visual" "chain-analysis-new" "chain-converage.war";且chain-converage.war只能单版本发布;在A版
apps_list=("chain-retail" "chain" "psm" "chain-visual" "chain-analysis-new")

function nginx_status(){
	flag=`netstat -lnpt|grep ${nginx_port}|wc -l`
	if [ $flag -ne 1 ];then
		echo -e "\033[5;41;33m nginx端口${nginx_port}服务状态为关闭 \033[0m"   ## 红底黄字 字体闪烁显示
		echo -e "\033[5;41;33m 请检查nginx服务 \033[0m"   ## 红底黄字 字体闪烁显示
		echo "重启nginx服务参考命令:/app/nginx/nginx "
		exit 2
	fi

}

function version_status(){
	echo "*****服务所在版本******"
	for ((i=0;i<${#apps_list[@]};i++ )) ;do
		if [ -f /app/nginx/conf/router/${apps_list[i]}.router.conf ];then 
			version=`grep default  /app/nginx/conf/router/${apps_list[i]}.router.conf |awk '{print $2}'|awk -F '_' '{print $2}'|tr '[a-z]' '[A-Z]'`
			version_status=${apps_list[i]}_${version}
			echo "该应用${apps_list[i]} 版本为:${version_status} "
		else
			echo -e "\033[5;41;33m 未发现该应用${apps_list[i]}版本路由文件 \033[0m"
		fi
	done
	echo "********************"
}

nginx_status
version_status

