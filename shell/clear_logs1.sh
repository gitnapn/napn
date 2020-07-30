#!/bin/bash 
version=$1
if [ "${version}" == "" ];then echo "a或者b";exit 1;fi

for i in `ls /app/tomcat/${version}/`
do
  if [ -d /app/tomcat/${version}/${i}/logs ];then
  cd /app/tomcat/${version}/${i}/logs
  num=`ls -l | grep '^-' | wc -l`
  if [ $num -gt 5 ];
  then
   #计算超过5个多少
   num=`expr $num - 5`
   clean=`ls -tr | head -$num | xargs`
   echo "will delete file:"
   pwd
   echo ${clean}
   ls -tr | head -$num | xargs  rm 
  fi
  fi
done
