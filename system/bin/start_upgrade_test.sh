#!/system/bin/sh

usage()
{
    echo "usage: start_upgrade_test.sh <-option> [param]"
    echo "  -h              show usage"
    echo "  -e              execute the upgrade_test "
    echo "  -f <file>       set the upgrade_test's 'log save file (not upgrade test result) "
    echo "  -s              save the upgrade_test's log. default file : /blackbox/system/upgrade_test.log"
    echo "  -r              reload the upgrade_test"
}

TEST_PARAM_FILE="/data/upgrade_test_param"
property=""
upgrade_test_log_path=/blackbox/system/upgrade_test.log
save_log=0;
execute=0;
reload_cmd=0
# main run begin
while getopts  "hef:sr" arg
do
    case $arg in
        h)
            usage
            ;;
        e)
            execute=1
            ;;
        f)
            upgrade_test_log_path=$OPTARG
            ;;
        s)
            save_log=1
            ;;
        r)
            reload_cmd=1
            ;;
        ?)
            usage
            ;;
    esac
done

if [ $reload_cmd -eq 1 -a $execute -eq 1 ]; then
    echo "can not reload cmd and execute upgrade_test at the same time"
    usage
    exit 1
fi

if [ $save_log -eq 1 ]; then
    echo save upgrade_test log to $upgrade_test_log_path > /dev/kmsg
    echo -e "\n\n!!!new boot start!!!\n\n">> $upgrade_test_log_path
    logcat -v threadtime -f $upgrade_test_log_path -r4096 -n7 DUSS7F:I *:S &
fi

if [ $reload_cmd -eq 1 ]; then
    echo try to reload the upgrade test > /dev/kmsg
    upgrade_test load_cmd &
fi

if [ $execute -eq 1 ]; then
    if [ -n "$DJI_UPGRADE_TEST_PARAM_FILE" ]; then
        TEST_PARAM_FILE=$DJI_UPGRADE_TEST_PARAM_FILE
        echo "use ($TEST_PARAM_FILE) as TEST_PARAM_FILE" > /dev/kmsg
    else
        echo "use default TEST_PARAM_FILE ($TEST_PARAM_FILE)" > /dev/kmsg
    fi
    if [ -f $TEST_PARAM_FILE ]; then
        echo "execute upgrade test: \" upgrade_test $(cat $TEST_PARAM_FILE) \"" > /dev/kmsg
        upgrade_test $(cat $TEST_PARAM_FILE)
    else
        echo "the test param file ($TEST_PARAM_FILE) is not valid" > /dev/kmsg
    fi
fi
