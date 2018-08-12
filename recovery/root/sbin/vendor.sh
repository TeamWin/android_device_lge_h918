#!/sbin/sh
if [ `blkid /dev/block/bootdevice/by-name/vendor | grep -c ext4` -ge 1 ] ; then
	echo '/vendor /dev/block/bootdevice/by-name/vendor	ext4	flags=backup;wipeingui'>>/etc/recovery.fstab
	echo '/vendor_image /dev/block/bootdevice/by-name/vendor	emmc	flags=backup=0;flashimg'>>/etc/recovery.fstab
	if [ ! -d /vendor ]; then # if not a directory, it either doesnt exist or is a symlink
		if [ -L /vendor ]; then
			rm /vendor
		fi
	fi
mkdir /vendor
fi
