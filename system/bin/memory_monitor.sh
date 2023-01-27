#!/system/bin/sh

#############################################
# Memory Monitor
# Version Information
#	v1.0 MSM8953 compatible
#
#############################################

version=1.0

loop_delay=1
loop_count=0
max_loop_number=0
prev_cpu_use=0
prev_cpu_total=0

cpu_load_total=0
cpuL_freq_total=0
cpuL_temp_total=0

prev_cpuB_use=0
prev_cpuB_total=0

skip_first=1
last_log_date=0

new_cpuL_clk=0
new_cpuB_clk=0
new_gpu_clk=0
new_ddr_clk=0

memory_dji_fly=0
memory_system_framework=0
memory_ion=0
memory_surface=0
memory_omx=0
memory_kernel=0

memory_total_swap=0

proc_MemTotal=0
proc_MemAvailable=0
proc_MemFree=0
proc_Buffers=0
proc_Cached=0
proc_SwapTotal=768
proc_SwapFree=0
proc_SwapUsed=0
ion_memory=0
dji_fly_kgsl=0

top_iow=0
top_cpu=0




echo ""
echo "Memory Monitor for MSM8953 , Version: "$version
echo "\tF - Freq(MHz)"
echo "\tL - Load(%)"
echo "\tT - Temperature(C)"
echo ""
echo "[Model]: "`getprop ro.product.model`
echo "[Firmware]: "`getprop ro.build.description`
echo "[Kernel]: "`cat /proc/version`
echo ""


echo ""

time_begin=$((`date +%s`+2))
last_log_date=`date '+%m-%d %H:%M:%S.000'`
#echo "last_log_date=$last_log_date"
title_str="UPTIME(s) CPU(0/4/7/L/T)\tGPU(F/L/T)\tDDR(F/L)\tTotal/MemAvailable/MemFree/Buffers/Cached/SwapUsed/MemUsed/ION/FlyKgsl \t Size/Avail"

memory_use() {
    proc_MemTotal=`head -4 /proc/meminfo |awk 'NR==1{b=$2;printf "%d", b/1024}'`
	proc_MemAvailable=`head -4 /proc/meminfo |awk 'NR==3{b=$2;printf "%d", b/1024}'`
	proc_MemFree=`head -4 /proc/meminfo |awk 'NR==2{b=$2;printf "%d", b/1024}'`
	proc_Buffers=`head -4 /proc/meminfo |awk 'NR==4{b=$2;printf "%d", b/1024}'`
	proc_Cached=`head -5 /proc/meminfo |awk 'NR==5{b=$2;printf "%d", b/1024}'`
	proc_SwapUsed=`awk '/SwapTotal/{total=$2}/SwapFree/{free=$2}END{printf "%d",(total-free)/1024}'  /proc/meminfo`
	memory_used=`expr ${proc_MemTotal} - ${proc_MemAvailable} + ${proc_SwapUsed}`
	 ###add all kgsl #`tail -1  /d/dma_buf/bufinfo  |awk '{b=$4;printf "%d", b/(1048576)}'`
	ion_memory=`cat /d/kgsl/proc/[1-9]*/mem | grep -v gpuaddr |awk '{sum+=$3}END{printf "%d", sum/(1048576)}'`
	pid=$(pidof "dji.go.v5")
	dji_fly_kgsl=`cat /d/kgsl/proc/$pid/mem  |awk '{sum+=$3}END{printf "%d", sum/(1048576)}'`


    #echo "memory_used: $memory_used"
    ##echo "memory_cached: $memory_cache"
    #echo "proc_MemTotal: $proc_MemTotal"
	#echo "proc_MemAvailable: $proc_MemAvailable"
	#echo "proc_MemFree: $proc_MemFree"
	#echo "proc_Buffers: $proc_Buffers"
	#echo "proc_Cached: $proc_Cached"
	#echo "proc_SwapUsed: $proc_SwapUsed"
	#echo  "ion_memory: $ion_memory"
}
while true
do
up_time=`uptime | busybox awk '{print substr($1,0,8)}'`

cpuL_freq=0
if [ -f "/sys/bus/cpu/devices/cpu0/cpufreq/cpuinfo_cur_freq" ]; then
cpuL_freq=`cat /sys/bus/cpu/devices/cpu0/cpufreq/cpuinfo_cur_freq`
cpuL_freq=$(($cpuL_freq/1000))
cpuB_freq=`cat /sys/bus/cpu/devices/cpu4/cpufreq/cpuinfo_cur_freq`
cpuB_freq=$(($cpuB_freq/1000))
cpuS_freq=`cat /sys/bus/cpu/devices/cpu7/cpufreq/cpuinfo_cur_freq`
cpuS_freq=$(($cpuS_freq/1000))
fi
#echo "CPUL Freq: "$cpuL_freq" MHz"

cpu_load=0
eval $(cat /proc/stat | grep "cpu " | busybox awk '
{
    printf("cpu_use=%d; cpu_total=%d;",$2+$3+$4+$6+$7+$8, $2+$3+$4+$5+$6+$7+$8)
}
')
cpu_load=$((($cpu_use-$prev_cpu_use)*100/($cpu_total-$prev_cpu_total)))
#echo "CPU Load: $cpu_load""%"
prev_cpu_use=$cpu_use
prev_cpu_total=$cpu_total

cpu_temp=0
if [ -f "/sys/class/thermal/thermal_zone6/temp" ]; then
cpu_temp=`cat /sys/class/thermal/thermal_zone6/temp`
cpu_temp=$(($cpu_temp/1000))
fi
#echo "CPU Temp: $cpu_temp"

gpu_freq=0
gpu_load=0
if [ -f "/sys/class/kgsl/kgsl-3d0/clock_mhz" ]; then
gpu_freq=`cat /sys/class/kgsl/kgsl-3d0/clock_mhz`

eval $(cat /sys/class/kgsl/kgsl-3d0/gpu_busy_percentage | busybox awk  -F '@' '
{
    printf("gpu_load=%d",$1)
}
')
fi
#echo "GPU Freq: $gpu_freq MHz"
#echo "GPU Load: $gpu_load""%"

gpu_temp=0
if [ -f "/sys/class/thermal/thermal_zone16/temp" ]; then
gpu_temp=`cat /sys/class/thermal/thermal_zone16/temp`
gpu_temp=$(($gpu_temp/1000))
fi
#echo "GPU Temp: $gpu_temp"

ddr_freq=0
ddr_load=0
if [ -f "/sys/kernel/debug/clk/bimc_clk/measure" ]; then
ddr_freq=`cat /sys/kernel/debug/clk/bimc_clk/measure`
ddr_freq=$(($ddr_freq/1000000))
fi

#data partition avaiable space
data_size=`df -h /data | grep data |awk 'NR == 1' | awk {'print $2'}`
data_used=`df -h /data | grep data |awk 'NR == 1' | awk {'print $3'}`
data_Avail=`df -h /data | grep data |awk 'NR == 1' | awk {'print $4'}`
#echo "data_size: $data_size"


memory_use

if [ $(($loop_count%20)) -eq 0 ]; then
    echo $title_str
fi

busybox printf "%s  %03d/%02d/%02d/%02d/%02d\t%03d/%02d/%02d\t%03d/%03d \t%02d\t%02d%12d\t     %-5d   %02d    %02d      %02d   %02d    %02d\t %02s %s\n" $up_time $cpuL_freq $cpuB_freq $cpuS_freq $cpu_load $cpu_temp $gpu_freq $gpu_load $gpu_temp $ddr_freq $ddr_load $proc_MemTotal $proc_MemAvailable $proc_MemFree $proc_Buffers $proc_Cached $proc_SwapUsed $memory_used $ion_memory $dji_fly_kgsl $data_size $data_Avail

sleep $loop_delay
done
