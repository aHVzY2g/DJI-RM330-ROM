#!/system/bin/sh

cmd=$1
option=$2

tmp_file="/tmp/modem_info.tmp"

if [ ! -d /tmp/ ];then
    mkdir tmp
fi

touch $tmp_file

alias v1_sender="dji_mb_ctrl -S test -R diag"
alias awk="busybox awk"

parse_cps() {
     rsp_data=$(tail -n 2 $1)
     ret_code=$(echo $rsp_data | awk '{print $1}')
     role=$(echo $rsp_data | awk '{print $2}')
     state=$(echo $rsp_data | awk '{print $3}')

     if [ is$ret_code != is"00" ]; then
         echo "Get CPS Failed!"
         return -1
     fi

     case $role in
         00)
             role_str="UAV"
             ;;
         01)
             role_str="GND"
             ;;
         02)
             role_str="GLASS"
             ;;
         *)
             role_str="Unknown"
             ;;
     esac

     case $state in
         00)
             state_str="Idle"
             ;;
         01)
             state_str="Pair"
             ;;
         02)
             state_str="Connected"
             ;;
         03)
             state_str="Loss"
             ;;
         04)
             state_str="CPA7_ERR"
             ;;
         05)
             state_err="DSP_ERR"
             ;;
         06)
             state_err="AMT"
             ;;
         *)
             state_str="Unknown"
             ;;
     esac

     echo "Mode: $role_str  CPS: $state_str"
}

parse_ver() {
     rsp_data=$(tail -n 3 $1)
     ret_code=$(echo $rsp_data | awk '{print $1}')

	 ap_main=$(echo $rsp_data | awk '{print $26}')
	 ap_sub=$(echo $rsp_data | awk '{print $25}')
	 ap_last=$(echo $rsp_data | awk '{print $24}')
	 ap_dev=$(echo $rsp_data | awk '{print $23}')

	 cp_main=$(echo $rsp_data | awk '{print $22}')
	 cp_sub=$(echo $rsp_data | awk '{print $21}')
	 cp_last=$(echo $rsp_data | awk '{print $20}')
	 cp_dev=$(echo $rsp_data | awk '{print $19}')

     if [ is$ret_code != is"00" ]; then
         echo "Get CPS Failed!"
         return -1
     fi
	 
	 echo "AP VERSION:$ap_main.$ap_sub.$ap_last.$ap_dev"
	 echo "CP VERSION:$cp_main.$cp_sub.$cp_last.$cp_dev"
}

v1_ping() {
    case $1 in
        uav|UAV)
            v1_sender -g 9 -t 0 -s 0 -c 1 -0
            ;;
        gnd|GND)
            v1_sender -g 14 -t 0 -s 0 -c 1 -0
            ;;
        *)
            echo "Unsupport Target, Only support uav & gnd"
            ;;
    esac
}

if [ is$cmd == is"pair" -o is$cmd == is"auto" ]; then
    echo "Pair..."
    v1_sender -g 14 -t 0 -s 6 -c 0x2f -1 0x01
elif [ is$cmd == is"reboot" ]; then
    echo "Reboot..."
    v1_sender -g 14 -t 0 -s 9 -c 0x55 0000
elif [ is$cmd == is"reverse" ]; then
    echo "Reverse..."
    v1_sender -g 14 -t 0 -s 9 -c 0x55 0001
elif [ is$cmd == is"cps" ]; then
    v1_sender -g 14 -t 0 -s 9 -c 0x55 0002 > $tmp_file
    parse_cps $tmp_file
elif [ is$cmd == is"VER" ]; then
    v1_sender -g 14 -t 0 -s 0 -c 1 > $tmp_file
    parse_ver $tmp_file
elif [ is$cmd == is"ping" ]; then
    v1_ping $option
elif [ is$cmd == is"sysreboot" ]; then
    echo "Reset Modem!"
    v1_sender -g 14 -t 4 -s 0 -c 0x0B
fi

