#!/system/bin/sh

console="/dev/kmsg"

add_date()
{
	date=`date`
	echo ${date} > ${console}
}

while [ true ]
do
	sleep 10

	add_date
done
