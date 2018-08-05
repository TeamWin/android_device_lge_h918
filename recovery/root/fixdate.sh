#!/sbin/ash
#This script fixes the time in TWRP for stock rom users
#stock and Lineage seem to produce ats files with different epochs and by default
#I made Lineage's time accurate

until pids=$(pidof recovery)
do
    sleep 1
done
sleep 2

export year=`date +%Y`
export checked=$1
export rom=$2
if [ -z "$checked" ]; then
#check if a stock rom and set a flag so it wont recheck on the same boot
	mount /system -o ro
	if grep lge.swversion /system/build.prop ; then
		export rom='stock'
		exit
	elif grep ro.cm.build.version /system/build.prop; then
		export rom='lin14'
	else  #lin15 or other
		export rom='other'
	fi
	umount /system
	export checked=1
fi
until grep -m 1 "Fixup_Time" /tmp/recovery.log; do
	sleep 1
done
case $rom in
	stock) exit;; #stock will be fine, should have exited above anyway
	lin14)		export year=`expr $year - 46`
		if [[ $year -ge 2030 ]]; then
			exit
		fi
		#lineage 14 had date 46 years in the future but otherwise correct
		date $(date +%m%d%H%M)$year.$(date +%S)
		export fixed=1
		;;
	*) #take a guess based on /data/data
		if [ ! -d /data/data ]; then
			sleep 12
			if [ ! -d /data/data ]; then
				exit #data not mounted, give up
			fi
		fi
		if [ `date -r /data/data +%Y` -gt `date -r /data/media/0 +%Y` ]; then
			export dir='/data/data'
		else
			export dir='/data/media/0'
		fi
		date $(date -r $dir +%m%d%H%M%Y)
		export fixed=1
		;;
esac
##On superv20 us996 10o I had it come up 2017 so handling this case
#if [ `date +%Y` -eq 2017 ]
#then
#date $(date +%m%d%H%M)2018.$(date +%S)
#echo "Did 2017 date nudge" >>/twrp-date.log
sleep 4
# Now not sure about the next comment, so being more aggressive and checking every 6 seconds.
#date gets switched back to 1972 20 seconds after twrp starts so waiting 19 seconds + 2 seconds to fix on the next run
if [ ! -z $fixed ]; then
	exit
fi
exec /fixdate.sh "$checked" "$rom"

