#!/sbin/sh
#This script fixes the time in TWRP for Lineage rom users
#stock and Lineage seem to produce ats files with different epochs

until pids=$(pidof recovery)
do
    sleep 1
done
sleep 2

export year=`date +%Y`
export checked=$1
export rom=$2

export fixed=$3; if [ -z "$fixed" ]; then export fixed=0; fi
echo $fixed
if [ -z "$checked" ]; then
#check if a stock rom and set a flag so it wont recheck on the same boot
	if [ ! -f /system/build.prop ]; then
		mount /system -o ro
	fi
	if grep lge.swversion /system/build.prop ; then
		export rom='stock'
	elif grep ro.cm.build.version /system/build.prop; then
		export rom='lin14'
	elif [ $(grep ro.build.version.release /system/build.prop | awk -F = '{print $2}' | awk -F . -v OFS='' '{print $1,$2}') -ge 81 ]; then
		export rom='aosp-oreo' #assume anything 8.1+ uses a similar kernel to lineage 15.1
	elif grep 'ro.lineage.build.version=15.1' /system/build.prop; then
		export rom='lin15'
	else #other
		export rom='other'
	fi
#	umount /system
	export checked=1
fi
until grep -m 1 "Fixup_Time" /tmp/recovery.log; do
	sleep 1
done
case $rom in
	stock) #stock will be mostly fine, year might be off so lets fix
		#possibly just an alpha kernel bug?
		if [ ! -d /data/data ]; then
			sleep 12
			if [ ! -d /data/date ]; then
				exit #data not mounted, giving up
			fi
		fi
		if [ `date -r /data/data +%Y` -gt `date -r /data/media/0 +%Y` ]; then
			export dir='/data/data'
		else
			export dir='/data/media/0'
		fi
		date $(date +%m%d%H%M)$(date -r $dir +%Y)
		;;

	lin14)		export year=`expr $year - 46`
		if [[ $year -lt 2018 ]]; then
			exit
		fi
		#lineage 14 had date 46 years in the future but otherwise correct
		date $(date +%m%d%H%M)$year.$(date +%S)
		export fixed=$(expr 1 + "$fixed")
		;;
	lin15 | aosp-oreo ) #assume anything oreo 8.1+ is using lineage 15's offset or at least close
		export year=`expr $year - 47`
		if [[ $year -lt 2018 ]]; then
			exit
		fi
		date $(date +%m%d%H%M)$year.$(date +%S)
		export fixed=$(expr 1 + "$fixed")
	;;
	*) #take a guess based on /data/data
		if [ $(date +%Y) -ge 2018 ]; then
			export fixed=2 #if the year is correct leave it alone
			exit
		fi
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
		export fixed=$(expr 1 + "$fixed")
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
echo $fixed
if [  $fixed  -eq 2 ]; then
	exit #runscript twice because twrp runs its own fixup twice if data is encrypted
fi
exec /sbin/fixdate.sh "$checked" "$rom" "$fixed"

