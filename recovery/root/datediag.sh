#!/sbin/ash
until pids=$(pidof recovery)
do
    sleep 1
done
export datelog='/twrp-date.log'
echo '0' `date` >$datelog
chmod 0666 $datelog
sleep 1
for x in `seq 1 90`
do
echo $x `date` >>$datelog
mkdir /sdcard/TWRP
cp $datelog /sdcard/TWRP/
chmod 0666 /sdcard/TWRP$datelog
chmod 777 /sdcard/TWRP #unhide folder so log can be seen
sleep 1
done
