#!/system/bin/sh

enc_dir=/mnt/encrypt
/system/bin/fastboot flash cmpu_otp $enc_dir/otp.sec
[ $? -ne 0 ] && echo "flash otp failed" && exit 4

start dji_sdrs_agent
exit 0
