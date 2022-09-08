#!/system/bin/sh

stop dji_sdrs_agent

# reset sparrow
modem_reset.sh

while true;
do

usbfile="/sys/kernel/debug/usb/devices"

bootrom=`grep ProdID=0040 $usbfile`
bootloader=`grep ProdID=d00d $usbfile`
brexist=`echo $bootrom | wc -w`
blexist=`echo $bootloader | wc -w`

pro_dir=/mnt/encrypt

if [ $brexist -gt 0 ] ; then
    echo ------$bootrom exist info $brexist

    # switch sparrow state to production
    brload $pro_dir/bootarea.img
    [ $? -ne 0 ] && echo "loading bootarea failed" && exit 1
    sleep 0.5
fi

if [ $blexist -gt 0 ] ; then
    echo ------$bootloader exist info $blexist

    fastboot flash cmpu_pro $pro_dir/bootarea.img
    [ $? -ne 0 ] && echo "flash pro failed" && exit 2

    sleep 0.5
    start dji_sdrs_agent
    exit 0
fi

done;
