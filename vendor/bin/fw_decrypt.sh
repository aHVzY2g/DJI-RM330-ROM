#!/vendor/bin/sh

input_file_path="/vendor/app/DJI_FLY_32_SIGN/fly_app.img"
output_file_path="/data/fly.apk"

flag_path="/data/dec_flag.bin"

if [ ! -f "$flag_path" ];then
	echo "need decrypt fly app"

	/system/bin/dji_decrypt $input_file_path $output_file_path 51200
	if [ "$?" == "0" ];then
		echo "fist success"
	else
		echo "dec failed,try again"
		/system/bin/dji_decrypt $input_file_path $output_file_path 51200
	fi

	if [ "$?" == "0" ];then
		touch $flag_path
	else
		echo "fw_decrypt failed!"
	fi

else

	echo "do not need decrypt fly app"
fi

