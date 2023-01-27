#!/system/bin/sh

while true;do
ip=$(getprop net.dns2)
if [ -n "$ip"  ];then
ping -c 60 -e $ip
#echo "round"
#echo $(ping -c 60 -e $ip)
fi
sleep 1
done