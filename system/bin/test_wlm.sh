#! /bin/bash
readonly cmd_link_sw_trig_host_type=14
readonly cmd_link_sw_trig_host_idx=7
readonly trig_cmd_set=0x51
readonly trig_cmd_id=0x2
readonly test_cmd_set=0x51
readonly test_cmd_id=0x9

trig_host_type=14
trig_host_idx=7
last_cmd_mode=0
curr_cmd_mode=0

mode_name[1]="sdr_only"
mode_name[2]="lte_only"
mode_name[3]="hybrid_lte_sdr"
reason[1]="timeout"
reason[2]="hardware unprepared"
reason[3]="agent unprepared"
reason[4]="route switch failed"
reason[5]="task busy"
reason[6]="repeat request"
reason[7]="no device"
reason[8]="internal failure"

#
# 0 sdr_only       --> lte_only
# 1 lte_only       --> sdr_only
# 2 sdr_only       --> hybrid_lte_sdr
# 3 hybrid_lte_sdr --> lte_only
# 4 lte_only       --> hybrid_lte_sdr
# 5 hybrid_lte_sdr --> sdr_only
#
cmd_link_sw_cnt=0
cmd_link_sw_test_cases=('01FFFF' '02FFFF' '01FFFF' \
                        '03FFFF' '02FFFF' '03FFFF')
total_cnt=0
pass_cnt=0
fail_cnt=0
fail_mb_ctrl_cnt=0

wlm_echo()
{
    echo "[`date`] $*"
}

usage()
{
   echo "Usage: test_wlm.sh [function] [args]"
   echo ""
   echo "   function:"
   echo "       -l link mode switch. args (command, liveview, data)"
   echo "   examples:"
   echo "       test_wlm.sh -l command"
   echo "       test_wlm.sh -l liveview"
   echo "       test_wlm.sh -l data"
}

hex_le32()
{
    local byte1=$((16#$1))
    local byte2=$((16#$2))
    local byte3=$((16#$3))
    local byte4=$((16#$4))

    echo $((byte1 + (byte2 << 8) + (byte3 << 16) + (byte4 << 24)))
}

command_link_sw_trig_prepare()
{
    let cmd_link_sw_cnt+=1

    cmd_link_sw_cnt=$((cmd_link_sw_cnt % 6))
    trig_msg_payload=${cmd_link_sw_test_cases[$cmd_link_sw_cnt]}

    curr_cmd_mode=${trig_msg_payload:1:1}
    trig_host_type=$cmd_link_sw_trig_host_type
    trig_host_idx=$cmd_link_sw_trig_host_idx
}

command_link_sw_check_result()
{
    return 0
}

liveview_link_sw_trig_prepare()
{
    wlm_echo $FUNCNAME
}

liveview_link_sw_check_result()
{
    wlm_echo $FUNCNAME
}

common_data_link_sw_trig_prepare()
{
    wlm_echo $FUNCNAME
}

common_data_link_sw_check_result()
{
    wlm_echo $FUNCNAME
}

__test_link_mode_switch()
{
    local channel=$1
    local rc resp
    local trig_prepare_func check_result_func

    wlm_echo "test channel $channel"

    case x$channel in
    x"command")
       trig_prepare_func=command_link_sw_trig_prepare
       check_result_func=command_link_sw_check_result
       ;;

    x"liveivew")
       trig_prepare_func=liveview_link_sw_trig_prepare
       check_result_func=liveview_link_sw_check_result
       ;;

    x"common_data")
       trig_prepare_func=common_data_link_sw_trig_prepare
       check_result_func=common_data_link_sw_check_result
       ;;

    *) wlm_echo "invalid channel $channel"; exit 1;
    esac

    # generate trigger msg payload
    eval $trig_prepare_func
    wlm_echo "trigger msg payload" $trig_msg_payload

    # trigger
    let total_cnt+=1
    resp=$(dji_mb_ctrl -R local -g $trig_host_type -t $trig_host_idx \
           -s $trig_cmd_set -c $trig_cmd_id $trig_msg_payload)
    rc=$?

    if [ $rc -ne 0 ]; then
        wlm_echo "$resp"
        wlm_echo "failed to trigger link mode swich, return code $rc"
        let fail_mb_ctrl_cnt+=1
        let total_cnt-=1
        return
    fi

    resp=(${resp##*data:})

    [ ${resp[0]} -ne 0 ] && {
        wlm_echo "failed to trigger link switch, MB errno ${resp[0]}"
        let fail_cnt+=1
        return
    }

    [ ${resp[1]} -ne 0 ] && {
        wlm_echo "failed to trigger link switch, reason ${reason[${resp[1]}]}"
        let fail_cnt+=1
        return
    }

    # check result
    eval $check_result_func
    rc=$?

    # statistics
    if [ $rc -ne 0 ]; then
        let fail_cnt+=1
    else
        let pass_cnt+=1
    fi
}

test_link_mode_switch()
{
    local period_s=0.5

    while true; do
        __test_link_mode_switch $@
        wlm_echo "link_mode statistics: total[$total_cnt] pass[$pass_cnt] fail[$fail_cnt] mb_ctrl_fail[$fail_mb_ctrl_cnt]"
        wlm_echo "----------------------------------------------------------------------------"
        sleep $period_s
    done
}

wlm_test()
{
    echo $#
    if [ $# -lt 1 ]; then
        wlm_echo "invalid argument number"
        usage
        exit 1
    fi

    while getopts "l:" arg; do
        case $arg in
        'l')
            test_link_mode_switch $OPTARG
            ;;

        ?) wlm_echo "invalid argument $arg"; exit 1;;
        *) wlm_echo "invalid option";        exit 1;;
        esac
    done
}

wlm_test $@
