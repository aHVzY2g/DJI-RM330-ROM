#!/system/bin/sh

enc_dir=/mnt/encrypt

stop dji_sdrs_agent

# reset sparrow
resetpin=123
echo $resetpin > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$resetpin/direction
echo 0 > /sys/class/gpio/gpio$resetpin/value
sleep 0.5
echo 1 > /sys/class/gpio/gpio$resetpin/value

# enc sparrow
/system/bin/brload $enc_dir/bootarea.img
[ $? -ne 0 ] && echo "loading bootarea failed" && exit 1

/system/bin/fastboot flash cmpu_kdr $enc_dir/pro_prak.pub.mon
[ $? -ne 0 ] && echo "flash kdr failed" && exit 2

/system/bin/fastboot get_staged $enc_dir/upload.bin
[ $? -ne 0 ] && echo "get upload.bin failed" && exit 3

exit 0
