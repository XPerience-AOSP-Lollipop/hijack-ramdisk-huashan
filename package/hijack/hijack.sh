#!/temp/ash
#
# ramdisk hijack for Xperia SP 4.3 version
# Original author: Peter Nyilas - dh.harald@XDA
#
# modified by: Bagyusz
#
# 2014.03.03
#
###############################################

export PATH=/temp:$PATH

LED_RED="/sys/class/leds/LED1_R/brightness"
LED_RED_CURRENT="/sys/class/leds/LED1_R/led_current"
LED_BLUE="/sys/class/leds/LED1_B/brightness"
LED_BLUE_CURRENT="/sys/class/leds/LED1_B/led_current"
LED_GREEN="/sys/class/leds/LED1_G/brightness"
LED_GREEN_CURRENT="/sys/class/leds/LED1_G/led_current"

cwm_line () {
	mount -o remount,rw rootfs /
	cd /
# Stop services

# Initialize system clock.
        ### set timezone...
        export TZ="$(getprop persist.sys.timezone)"
        ### start time_daemon...
        /system/bin/time_daemon &
        sleep 5
        ### kill time_daemon...
        kill -9 $(ps | grep time_daemon | grep -v grep | awk -F' ' '{print $1}')

	for SVCRUNNING in $(getprop | grep -E '^\[init\.svc\..*\]: \[running\]' | grep -v ueventd)
	do
		SVCNAME=$(expr ${SVCRUNNING} : '\[init\.svc\.\(.*\)\]:.*')
		stop ${SVCNAME}
	done

	for RUNNINGPRC in $(ps | grep /system/bin | grep -v grep | grep -v chargemon | awk '{print $1}' ) 
	do
		kill -9 $RUNNINGPRC
	done

	for RUNNINGPRC in $(ps | grep /sbin/ | grep -v grep | awk '{print $1}' )
	do
		kill -9 $RUNNINGPRC
	done

        rm -r /sbin
	rm sdcard etc init* uevent* default*

        # setup tz.conf for init
        echo on init > /tz.conf
        echo export TZ "$(getprop persist.sys.timezone)" >> /tz.conf
        chmod 750 /tz.conf
        tar cf /zoneinfo.tar /system/usr/share/zoneinfo

}

#-----------------------------------------------------------------------------------------------

ramdisk_line () {
	mount -o remount,rw rootfs /
	cd /
# Stop services

        #ps > /temp/ps.txt

	for SVCRUNNING in $(getprop | grep -E '^\[init\.svc\..*\]: \[running\]' )
	do
		SVCNAME=$(expr ${SVCRUNNING} : '\[init\.svc\.\(.*\)\]:.*')
		stop ${SVCNAME}
		killall -9 ${SVCNAME}
	done

	for RUNNINGPRC in $(ps | grep /system/bin | grep -v grep | grep -v wipedata | awk '{print $1}' ) 
	do
		killall -9 $RUNNINGPRC
	done

	for RUNNINGPRC in $(ps | grep /sbin | grep -v grep | awk '{print $1}' )
	do
		killall -9 $RUNNINGPRC
	done

        #ps > /temp/ps2.txt


        # umount

        #mount > /temp/mount.txt

        ## /boot/modem_fs1
        umount -l /dev/block/mmcblk0p6
        ## /boot/modem_fs2
        umount -l /dev/block/mmcblk0p7
        ## /system
        umount -l /dev/block/mmcblk0p13
        ## /data
        umount -l /dev/block/mmcblk0p15
        ## /mnt/idd
        umount -l /dev/block/mmcblk0p10
        ## /cache
        umount -l /dev/block/mmcblk0p14
        ## /lta-label
        umount -l /dev/block/mmcblk0p12
        ## /sdcard (External)
        umount -l /dev/block/mmcblk1p1

	umount /system
	umount /data
	umount /mnt/idd
	umount /cache
	umount /lta-label

        ## SDcard

        # Internal SDcard umountpoint
	umount /sdcard
	umount /mnt/sdcard
	umount /storage/sdcard0

        # External SDcard umountpoint
	umount /sdcard1
	umount /ext_card
	umount /storage/sdcard1

        # External USB umountpoint
	umount /mnt/usbdisk
	umount /usbdisk
	umount /storage/usbdisk

        # legacy folders
	umount /storage/emulated/legacy/Android/obb
	umount /storage/emulated/legacy
	umount /storage/emulated/0/Android/obb
	umount /storage/emulated/0
	umount /storage/emulated

	umount /storage/removable/sdcard1
	umount /storage/removable/usbdisk
	umount /storage/removable
	umount /storage

	umount /mnt/shell/emulated/0
	umount /mnt/shell/emulated
	umount /mnt/shell

	## misc
	umount /mnt/obb
	umount /mnt/asec
	umount /mnt/secure/staging
	umount /mnt/secure
	umount /mnt
	umount /acct
	umount /dev/cpuctl
	umount /dev/pts
	umount /dev
	umount /sys/fs/selinux
	umount /sys/kernel/debug
	umount /sys
	umount /proc


        #mount > /temp/mount2.txt

	# clean /
	cd /
	rm -r /sbin
	rm -r /storage
	rm -r /mnt
	rm -f sdcard sdcard1 ext_card sepolicy seapp_contexts property_contexts file_contexts crashtag mr.log fstab* init* ueventd* default*

        #ls > /temp/ls.txt
}

# Trigger short vibration
echo '200' > /sys/class/timed_output/vibrator/enable
# Show blue led
echo '255' > $LED_BLUE
echo '255' > $LED_BLUE_CURRENT
echo '0' > $LED_GREEN
echo '0' > $LED_GREEN_CURRENT
echo '0' > $LED_RED
echo '0' > $LED_RED_CURRENT

for EVENTDEV in $(ls /dev/input/event*)
do
	SUFFIX="$(expr ${EVENTDEV} : '/dev/input/event\(.*\)')"
	cat ${EVENTDEV} > /temp/keyevent${SUFFIX} &
done

sleep 3

for CATPROC in $(ps | grep cat | grep -v grep | awk '{print $1;}')
do
	kill -9 ${CATPROC}
done

# turn off leds
echo '0' > $LED_BLUE
echo '0' > $LED_BLUE_CURRENT
echo '0' > $LED_GREEN
echo '0' > $LED_GREEN_CURRENT
echo '0' > $LED_RED
echo '0' > $LED_RED_CURRENT

sleep 1

hexdump /temp/keyevent* | grep -e '^.* 0001 0072 .... ....$' > /temp/keycheck

# vol+/-, boot recovery
if [ -s /temp/keycheck -o -e /cache/recovery/boot ]
then

	# Show blue led
	echo '0' > $LED_BLUE
	echo '0' > $LED_BLUE_CURRENT
	echo '255' > $LED_GREEN
	echo '255' > $LED_GREEN_CURRENT
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT

	rm /cache/recovery/boot
	cwm_line
	cd /
	tar xf /temp/recovery.tar
	sleep 1

	# turn off leds
	echo '0' > $LED_BLUE
	echo '0' > $LED_BLUE_CURRENT
	echo '0' > $LED_GREEN
	echo '0' > $LED_GREEN_CURRENT
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT

	chroot / /init
	sleep 2
else
	ramdisk_line
	cd /
	tar xf /temp/ramdisk.tar
	sleep 2
	chroot / /init
	sleep 3
fi
	
