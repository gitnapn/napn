#!/bin/bash

instance_name=`hostname -i `

service_rename=("LogServer_a" "opcNew_a" "smWeb_a" "smLtePortal_a" "saleResourceWeb_a" "ppmintf_a" "ppm_a" "offerManagerWeb_a" "channelWeb_a" "channel_manager_web_a" "SupportToolWeb_a" "timeDataWeb_a" "LogServer_b" "opcNew_b" "smWeb_b" "smLtePortal_b" "saleResourceWeb_b" "ppmintf_b" "ppm_b" "offerManagerWeb_b" "channelWeb_b" "channel_manager_web_b" "SupportToolWeb_b")
service_url=('http://127.0.0.1:12501/LogServer/ReceiveLogServlet' 'http://127.0.0.1:50101/opcNew/' 'http://127.0.0.1:50102/smWeb/sniffer.jsp' 'http://127.0.0.1:50103/smLtePortal/sniffer.jsp?' 'http://127.0.0.1:50104/saleResourceWeb/sniffer.jsp' 'http://127.0.0.1:50105/ppmintf/DEPServiceHttpPort?wsdl' 'http://127.0.0.1:50106/ppm/portal/offer_prod_intf.jsp?staffId=1001&areaId=2' 'http://127.0.0.1:50109/offerManagerWeb/index.jsp' 'http://127.0.0.1:50110/channelWeb/monitor/refreshInitCommonCfg' 'http://127.0.0.1:50112/channel-manager-web/channelService/index' 'http://127.0.0.1:50113/SupportToolWeb/inst/update/main' 'http://127.0.0.1:50114/timeDataWeb/service/intf.timeDataDealService/updateInstStatusOTListenMsgList' 'http://127.0.0.1:12551/LogServer/ReceiveLogServlet' 'http://127.0.0.1:50151/opcNew/' 'http://127.0.0.1:50152/smWeb/sniffer.jsp' 'http://127.0.0.1:50153/smLtePortal/sniffer.jsp?' 'http://127.0.0.1:50154/saleResourceWeb/sniffer.jsp' 'http://127.0.0.1:50155/ppmintf/DEPServiceHttpPort?wsdl' 'http://127.0.0.1:50156/ppm/portal/offer_prod_intf.jsp?staffId=1001&areaId=2' 'http://127.0.0.1:50159/offerManagerWeb/index.jsp' 'http://127.0.0.1:50160/channelWeb/monitor/refreshInitCommonCfg' 'http://127.0.0.1:50162/channel-manager-web/channelService/index' 'http://127.0.0.1:50163/SupportToolWeb/inst/update/main')


for((i=0;i<${#service_rename[@]};i++))
do
        echo "dialing_${service_rename[i]}_respond  $(curl -s -m 5 -o /dev/null -w "%{http_code}\n" ${service_url[i]})"
        echo "dialing_${service_rename[i]}_respond  $(curl -s -m 5 -o /dev/null -w "%{http_code}\n" ${service_url[i]})" |curl --data-binary @- http://10.128.97.83:30300/metrics/job/pushgateway_be/instance/${instance_name}
done

