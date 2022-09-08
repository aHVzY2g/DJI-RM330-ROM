#! /system/bin/sh
function performance_mode()
{
    echo performance > /sys/class/kgsl/kgsl-3d0/gpuclk
    echo performance > /sys/class/devfreq/soc\:qcom,cpubw/governor
    echo none > /sys/class/kgsl/kgsl-3d0/pwrscale
    echo 600000000 >/sys/class/kgsl/kgsl-3d0/gpuclk

    echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on
    echo 1 > /sys/class/kgsl/kgsl-3d0/force_bus_on
    echo 10000000 > /sys/class/kgsl/kgsl-3d0/idle_timer
    echo 0 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel
    echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor
    echo 650000000 > /sys/class/kgsl/kgsl-3d0/gpuclk
    echo 650000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq
    echo 650000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq

    stop perf-hal-2-1

    echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo performance >/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
    echo performance >/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
    echo performance >/sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
    echo performance >/sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo performance >/sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
    echo performance >/sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
    echo performance >/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
}

performance_mode
