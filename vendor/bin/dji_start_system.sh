#! /system/bin/sh
prop_log_memory=persist.sys.memory_monitor
value_log_memory=`getprop $prop_log_memory`
function memory_monitor()
{
    if [ "$value_log_memory" != "" ]; then
        echo "persist.sys.memory_monitor: '$value_log_memory' enable memory monitor" > /dev/kmsg
        logwrapper  memory_monitor.sh &
    fi
}

function mainroute()
{
    ip rule add from all lookup main pref 3000
    ip -6 rule add table main
}

function iproute()
{
    ip rule add from all lookup main pref 9999
    ip -6 rule add table main 
    busybox route add -net 192.168.41.0  netmask 255.255.255.0 gw 192.168.50.2
    busybox route add -net 192.168.100.0  netmask 255.255.255.0 gw 192.168.50.2
    busybox route add -net 192.168.101.0  netmask 255.255.255.0 gw 192.168.50.2

    busybox route add -net 192.168.120.0  netmask 255.255.255.0 gw 192.168.50.2
    busybox route add -net 192.168.121.0  netmask 255.255.255.0 gw 192.168.50.2
    busybox route add -net 192.168.130.0  netmask 255.255.255.0 gw 192.168.50.2
    busybox route add -net 192.168.131.0  netmask 255.255.255.0 gw 192.168.50.2
    busybox route add -net 192.168.140.0  netmask 255.255.255.0 gw 192.168.50.2
    busybox route add -net 192.168.141.0  netmask 255.255.255.0 gw 192.168.50.2
}
COUNTER=1
while [ "$COUNTER" -lt 3 ]; do
    COUNTER=$(($COUNTER+1))

    iproute
    ret_route=$?
    echo "the return value is $ret_route"
    if [ $? -ne 0 ]; then
      echo " dji_start_system.sh return ok"
      break;
    else
      echo " dji_start_system.sh failed counter: $COUNTER"
    fi

    sleep 5
done

## memory monitor
setprop persist.sys.memory_monitor 1
memory_monitor

logwrapper  wifi_info.sh &

## set dji performance mode
setprop dji.sys.perf 1

while true; do

    local upgrade_test=$(getprop "persist.upgrade.test")
    if [ $upgrade_test -ne 0 ]; then
      echo " in upgrade_test status, need check ip route main table sometime"
      main_table=$(ip rule | grep main)
      if [ -z "$main_table" ]; then
        mainroute
      fi
    else
      echo "the upgrade_test value is not set,break now"
      break;
    fi

    sleep 2
done

# pull up gpio 62 for lte dongel of rm510
#echo --pin 62 > /d/gpio_dbg/pin
#echo --dir 62 1 > /d/gpio_dbg/pin
#echo --pull 62 3 > /d/gpio_dbg/pin
#echo --out 62 1 > /d/gpio_dbg/pin

