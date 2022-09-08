#!/system/bin/sh

TEST_PARAM_FILE="/data/upgrade_test_param"

if [ $# == 0 ]; then
    echo The param is empty! Pls make sure the param is correct
    exit 1
fi


if [ -n "$DJI_UPGRADE_TEST_PARAM_FILE" ]; then
    TEST_PARAM_FILE=$DJI_UPGRADE_TEST_PARAM_FILE
    echo "use ($TEST_PARAM_FILE) as TEST_PARAM_FILE" > /dev/kmsg
else
    echo "use default TEST_PARAM_FILE ($TEST_PARAM_FILE)" > /dev/kmsg
fi

echo will trigger: upgrade_test $*
echo "$*" > $TEST_PARAM_FILE
start upgrade_test