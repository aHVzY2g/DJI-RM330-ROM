#!/system/bin/sh

#############################################
#
# Version Information
#	v1.9 MSM8953 compatible
#   v1.8 QCS8250 compatible
#   v1.7 RK3228 compatible
#   v1.6 disable VR mode by default, use "-V" to enable it.
#   v1.5 output sensor's min/avg/max latency
#   v1.4
#        add ddr clock setup and view ddr load info
#        Display the average value of the load/temp/fps etc.
#   v1.3 add cpu/gpu clocks setup
#        hardware_monitor.sh -c 816 -g 297 # CPU=816MHz, GPU=297MHz
#   v1.2 support vpu clock show
#   v1.1 support rk vr's FPS
#   v1.0 first version
#
#   Authors: cmy@rock-chips.com
#
#############################################

version=1.9

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


echo ""
echo "Hardware Monitor for MSM8953 , Version: "$version
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
title_str="UPTIME(s)\tCPU(0/4/7/L/T)\t\tGPU(F/L/T)\tVPU/HEVC(F)\tDDR(F/L)\tFPS\tBat(T)"

while true
do
up_time=`uptime | busybox awk '{print substr($3,0,8)}'`

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
#eval $(cat /d/clk/clk_summary | grep " pll_dpll" | busybox awk '
#{
#   printf("ddr_freq=%d", $4/1000000);
#}
#')
fi

#echo "ddr Freq: $ddr_freq MHz"
#echo "ddr Load: $ddr_load""%"

vdpu_freq=0
#eval $(cat /d/clk/clk_summary | grep " clk_vdpu" | busybox awk '
#{
#    if($2<=0)
#        printf("vdpu_freq=%d;", 0);
#    else
#        printf("vdpu_freq=%d;", $4/1000000);
#}
#')
#if [ $vdpu_freq == 0 ]; then
#eval $(cat /d/clk/clk_summary | grep " aclk_vpu" | busybox awk '
#{
#    if($2<=0)
#        printf("vdpu_freq=%d;", 0);
#    else
#        printf("vdpu_freq=%d;", $4/1000000);
#}
#')
#fi
#
##echo "vpu Freq: $vdpu_freq MHz"
#
hevc_freq=0
#eval $(cat /d/clk/clk_summary | grep " clk_hevc_core" | busybox awk '
#{
#    if($2<=0)
#        printf("hevc_freq=%d;", 0);
#    else
#        printf("hevc_freq=%d;", $4/1000000);
#}
#')

#echo "hevc_freq Freq: $hevc_freq MHz"
#logcat -v time -t "$last_log_date"
app_fps=0

bat_temp=0
if [ -f "/sys/class/power_supply/dji-bat/temp" ]; then
bat_temp=`cat /sys/class/power_supply/dji-bat/temp`
fi
#echo "BAT Temp: $bat_temp"

if [ $(($loop_count%20)) -eq 0 ]; then
    echo $title_str
fi

#echo "$up_time\t$cpu_freq/$cpu_load/$cpu_temp\t$gpu_freq/$gpu_load/$gpu_temp\t$vdpu_freq/$hevc_freq\t\t$ddr_freq/$ddr_load\t\t$sensor_min/$sensor_avg/$sensor_max\t$app_fps/$atw_fps/$left_count"

busybox printf "%s\t        %03d/%02d/%02d/%02d/%02d\t%03d/%02d/%02d\t%03d/%03d\t\t%03d/%02d\t\t%.1f\t%02d\n" $up_time $cpuL_freq $cpuB_freq $cpuS_freq $cpu_load $cpu_temp $gpu_freq $gpu_load $gpu_temp $vdpu_freq $hevc_freq $ddr_freq $ddr_load $app_fps $bat_temp

sleep $loop_delay
done
