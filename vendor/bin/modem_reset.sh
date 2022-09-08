#!/vendor/bin/sh

logfile=/mnt/modem_reset.log
if [ ! -f $logfile ] ; then
    touch $logfile
fi
echo "Reset modem..." >>$logfile

resetpin=123

echo $resetpin > /sys/class/gpio/export

echo out > /sys/class/gpio/gpio$resetpin/direction
echo 0 > /sys/class/gpio/gpio$resetpin/value

sleep 0.5

echo 1 > /sys/class/gpio/gpio$resetpin/value

echo "Release modem ..." >>$logfile