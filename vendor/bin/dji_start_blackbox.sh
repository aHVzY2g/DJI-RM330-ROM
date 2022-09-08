#! /system/bin/sh
# update boot index, this will be used by dji_blackbox temporarily
prop_boot_index=persist.sys.boot_index
last_boot_index=`getprop $prop_boot_index`
echo last_boot_index=$last_boot_index

if [ "$last_boot_index" == "" ]; then
    # record boot index for the first time
    setprop $prop_boot_index 1
    echo "record '$prop_boot_index' for the first time" > /dev/kmsg
else
    # if property exist, update boot index
    boot_index=$(($last_boot_index + 1))
	echo boot_index=$boot_index
    setprop $prop_boot_index $boot_index
    echo "update '$prop_boot_index': '$last_boot_index' -> '$boot_index'" > /dev/kmsg
fi

# start blackbox service
setprop dji.blackbox_service 1

# some services check mount.blackbox to determine whether blackbox_service
# has been triggered, thus the should been set here after blackbox_service started.
setprop mount.blackbox 1

