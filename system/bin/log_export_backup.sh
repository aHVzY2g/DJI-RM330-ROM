#! /system/bin/sh

echo "Start to backup logs to /sdcard/blackbox directory"

if [ ! -d "/sdcard/blackbox" ]; then
	mkdir -p /sdcard/blackbox
fi

if [ -d "/blackbox/info" ]; then
	cp -rf /blackbox/info /sdcard/blackbox/
	echo "Complete the info directory backup"
fi

if [ -d "/blackbox/dji_logs" ]; then
	cp -rf /blackbox/dji_logs /sdcard/blackbox/
	echo "Complete the dji_logs directory backup"
fi

if [ -d "/blackbox/mcu" ]; then
	cp -rf /blackbox/mcu /sdcard/blackbox/
	echo "Complete the mcu directory backup"
fi

cd /sdcard/blackbox

time=$(date "+%Y-%m-%d %H:%M:%S")
touch COPY-COMPLETE
echo ${time} > COPY-COMPLETE

echo "Complete backup logs to /sdcard/blackbox directory"