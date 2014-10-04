#!/temp/ash
#
# ramdisk hijack for Xperia SP 4.3 version
# Original author: Peter Nyilas - dh.harald@XDA
#
# modified by: Bagyusz
#
# 2014.04.30
#
###############################################

export PATH=/temp:$PATH

LED_RED="/sys/class/leds/LED1_R/brightness"
LED_RED_CURRENT="/sys/class/leds/LED1_R/led_current"
LED_BLUE="/sys/class/leds/LED1_B/brightness"
LED_BLUE_CURRENT="/sys/class/leds/LED1_B/led_current"
LED_GREEN="/sys/class/leds/LED1_G/brightness"
LED_GREEN_CURRENT="/sys/class/leds/LED1_G/led_current"

LED2_RED="/sys/class/leds/LED2_R/brightness"
LED2_RED_CURRENT="/sys/class/leds/LED2_R/led_current"
LED2_BLUE="/sys/class/leds/LED2_B/brightness"
LED2_BLUE_CURRENT="/sys/class/leds/LED2_B/led_current"
LED2_GREEN="/sys/class/leds/LED2_G/brightness"
LED2_GREEN_CURRENT="/sys/class/leds/LED2_G/led_current"

LED3_RED="/sys/class/leds/LED3_R/brightness"
LED3_RED_CURRENT="/sys/class/leds/LED3_R/led_current"
LED3_BLUE="/sys/class/leds/LED3_B/brightness"
LED3_BLUE_CURRENT="/sys/class/leds/LED3_B/led_current"
LED3_GREEN="/sys/class/leds/LED3_G/brightness"
LED3_GREEN_CURRENT="/sys/class/leds/LED3_G/led_current"

#-----------------------------------------------------------------------------------------------

recovery_ramdisk () {
	mount -o remount,rw rootfs /
	cd /
# Initialize system clock.
        ### set timezone...
        export TZ="$(getprop persist.sys.timezone)"
        ### start time_daemon...
        /system/bin/time_daemon &
        sleep 3
        ### kill time_daemon...
        kill -9 $(ps | grep time_daemon | grep -v grep | awk -F' ' '{print $1}')
#Stop services
	for SVCRUNNING in $(getprop | grep -E '^\[init\.svc\..*\]: \[running\]' | grep -v ueventd)
	do
		SVCNAME=$(expr ${SVCRUNNING} : '\[init\.svc\.\(.*\)\]:.*')
		stop ${SVCNAME}
	done

	for RUNNINGPRC in $(ps | grep /system/bin | grep -v grep | grep -v wipedata | awk '{print $1}' ) 
	do
		kill -9 $RUNNINGPRC
	done

	for RUNNINGPRC in $(ps | grep /sbin/ | grep -v grep | awk '{print $1}' )
	do
		kill -9 $RUNNINGPRC
	done

	sync

	#insmod exFAT module

	insmod /system/lib/modules/texfat.ko

        # umount

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

	umount -l /system
	umount -l /data
	umount -l /mnt/idd
	umount -l /cache
	umount -l /lta-label

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

	umount -l /mnt/obb
	umount -l /mnt/asec
	umount -l /mnt/secure/staging
	umount -l /mnt/secure
	umount -l /mnt
	umount -l /acct
	umount -l /dev/cpuctl
	umount -l /dev/pts
        umount -l /cache
        umount -l /proc
        umount -l /sys

	sync

	# clean /
	cd /
        rm -r /sbin
        rm -r /cache
        rm -r /storage
	rm -f sdcard sdcard1 ext_card etc init* uevent*

        # setup tz.conf for init
        echo on init > /tz.conf
        echo export TZ "$(getprop persist.sys.timezone)" >> /tz.conf
        chmod 750 /tz.conf
        cp /sbin/zoneinfo.tar /

}

#-----------------------------------------------------------------------------------------------

android_ramdisk () {
	mount -o remount,rw rootfs /
	cd /
# Stop services

	for SVCNAME in $(getprop | grep -E '^\[init\.svc\..*\]: \[running\]' | sed 's/\[init\.svc\.\(.*\)\]:.*/\1/g;')
	do
		stop $SVCNAME
	done

	for RUNNINGPRC in $(ps | grep /system/bin | grep -v grep | grep -v wipedata | awk '{print $1}' ) 
	do
		kill -9 $RUNNINGPRC
	done

	for RUNNINGPRC in $(ps | grep /sbin | grep -v grep | awk '{print $1}' )
	do
		kill -9 $RUNNINGPRC
	done

	sync

        # umount

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

	sync

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
	umount /sys/fs/selinux
	umount /sys/kernel/debug

	sync

	# clean /
	cd /
	rm -r /sbin
	rm -r /storage
	rm -r /mnt
	rm -f sdcard sdcard1 ext_card init*
}

## Knight Rider Light Bard (Beta v0.1 config by bagyusz)

        # fake data factory reset led fix
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT

	echo '32' > $LED3_RED
	echo '32' > $LED3_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
sleep 0.1
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
sleep 0.1
	echo '32' > $LED3_RED
	echo '32' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
sleep 0.1
	echo '0' > $LED3_RED
	echo '0' > $LED3_RED_CURRENT
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '32' > $LED_RED
	echo '32' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT
	echo '32' > $LED2_RED
	echo '32' > $LED2_RED_CURRENT
sleep 0.1
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
	echo '32' > $LED2_RED
	echo '32' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '0' > $LED2_RED
	echo '0' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
	echo '32' > $LED_RED
	echo '32' > $LED_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT
##1
	echo '32' > $LED3_RED
	echo '32' > $LED3_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
sleep 0.1
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
sleep 0.1
	echo '32' > $LED3_RED
	echo '32' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
sleep 0.1
	echo '0' > $LED3_RED
	echo '0' > $LED3_RED_CURRENT
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '32' > $LED_RED
	echo '32' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT
	echo '32' > $LED2_RED
	echo '32' > $LED2_RED_CURRENT
##
sleep 0.1
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
	echo '32' > $LED2_RED
	echo '32' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '0' > $LED2_RED
	echo '0' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
	echo '32' > $LED_RED
	echo '32' > $LED_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT
##2
sleep 0.1
	echo '32' > $LED3_RED
	echo '32' > $LED3_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
sleep 0.1
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
sleep 0.1
	echo '32' > $LED3_RED
	echo '32' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
sleep 0.3
	echo '0' > $LED3_RED
	echo '0' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
sleep 0.1
# Pulse RED light
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
sleep 0.1
	echo '96' > $LED3_RED
	echo '96' > $LED3_RED_CURRENT
	echo '96' > $LED_RED
	echo '96' > $LED_RED_CURRENT
	echo '96' > $LED2_RED
	echo '96' > $LED2_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '48' > $LED3_RED
	echo '48' > $LED3_RED_CURRENT
	echo '48' > $LED_RED
	echo '48' > $LED_RED_CURRENT
	echo '48' > $LED2_RED
	echo '48' > $LED2_RED_CURRENT
sleep 0.1
	echo '32' > $LED3_RED
	echo '32' > $LED3_RED_CURRENT
	echo '32' > $LED_RED
	echo '32' > $LED_RED_CURRENT
	echo '32' > $LED2_RED
	echo '32' > $LED2_RED_CURRENT
sleep 0.1
	echo '48' > $LED3_RED
	echo '48' > $LED3_RED_CURRENT
	echo '48' > $LED_RED
	echo '48' > $LED_RED_CURRENT
	echo '48' > $LED2_RED
	echo '48' > $LED2_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '96' > $LED3_RED
	echo '96' > $LED3_RED_CURRENT
	echo '96' > $LED_RED
	echo '96' > $LED_RED_CURRENT
	echo '96' > $LED2_RED
	echo '96' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT
##
sleep 0.1
	echo '96' > $LED3_RED
	echo '96' > $LED3_RED_CURRENT
	echo '96' > $LED_RED
	echo '96' > $LED_RED_CURRENT
	echo '96' > $LED2_RED
	echo '96' > $LED2_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '48' > $LED3_RED
	echo '48' > $LED3_RED_CURRENT
	echo '48' > $LED_RED
	echo '48' > $LED_RED_CURRENT
	echo '48' > $LED2_RED
	echo '48' > $LED2_RED_CURRENT
sleep 0.1
	echo '32' > $LED3_RED
	echo '32' > $LED3_RED_CURRENT
	echo '32' > $LED_RED
	echo '32' > $LED_RED_CURRENT
	echo '32' > $LED2_RED
	echo '32' > $LED2_RED_CURRENT
sleep 0.1
	echo '48' > $LED3_RED
	echo '48' > $LED3_RED_CURRENT
	echo '48' > $LED_RED
	echo '48' > $LED_RED_CURRENT
	echo '48' > $LED2_RED
	echo '48' > $LED2_RED_CURRENT
sleep 0.1
	echo '64' > $LED3_RED
	echo '64' > $LED3_RED_CURRENT
	echo '64' > $LED_RED
	echo '64' > $LED_RED_CURRENT
	echo '64' > $LED2_RED
	echo '64' > $LED2_RED_CURRENT
sleep 0.1
	echo '96' > $LED3_RED
	echo '96' > $LED3_RED_CURRENT
	echo '96' > $LED_RED
	echo '96' > $LED_RED_CURRENT
	echo '96' > $LED2_RED
	echo '96' > $LED2_RED_CURRENT
sleep 0.1
	echo '128' > $LED3_RED
	echo '128' > $LED3_RED_CURRENT
	echo '128' > $LED_RED
	echo '128' > $LED_RED_CURRENT
	echo '128' > $LED2_RED
	echo '128' > $LED2_RED_CURRENT

# Trigger short vibration
echo '100' > /sys/class/timed_output/vibrator/enable
sleep 0.2
echo '100' > /sys/class/timed_output/vibrator/enable

	echo '96' > $LED3_RED
	echo '96' > $LED3_RED_CURRENT
	echo '96' > $LED_RED
	echo '96' > $LED_RED_CURRENT
	echo '96' > $LED2_RED
	echo '96' > $LED2_RED_CURRENT

for EVENTDEV in $(ls /dev/input/event*)
do
	SUFFIX="$(expr ${EVENTDEV} : '/dev/input/event\(.*\)')"
	cat ${EVENTDEV} > /temp/keyevent${SUFFIX} &
done

sleep 3

for CATPROC in $(ps | grep cat | grep -v grep | awk '{print $1}')
do
	kill -9 ${CATPROC}
done

# turn off leds
	echo '0' > $LED3_RED
	echo '0' > $LED3_RED_CURRENT
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT
	echo '0' > $LED2_RED
	echo '0' > $LED2_RED_CURRENT

sleep 1

hexdump /temp/keyevent* | grep -e '^.* 0001 0073 .... ....$' > /temp/keycheck_up
hexdump /temp/keyevent* | grep -e '^.* 0001 0072 .... ....$' > /temp/keycheck_down

# vol+, boot Philz recovery
if [ -s /temp/keycheck_up -o -e /cache/recovery/boot ]
then

	# Show pink led
	echo '96' > $LED3_BLUE
	echo '96' > $LED3_BLUE_CURRENT
	echo '96' > $LED3_RED
	echo '96' > $LED3_RED_CURRENT

	echo '96' > $LED_BLUE
	echo '96' > $LED_BLUE_CURRENT
	echo '96' > $LED_RED
	echo '96' > $LED_RED_CURRENT

	echo '96' > $LED2_BLUE
	echo '96' > $LED2_BLUE_CURRENT
	echo '96' > $LED2_RED
	echo '96' > $LED2_RED_CURRENT

	rm /temp/keycheck_up
	rm /cache/recovery/boot
	recovery_ramdisk
	cd /
	tar xf /temp/philz.tar
	sync
	sleep 1

	# turn off leds
	echo '0' > $LED3_BLUE
	echo '0' > $LED3_BLUE_CURRENT
	echo '0' > $LED3_RED
	echo '0' > $LED3_RED_CURRENT

	echo '0' > $LED_BLUE
	echo '0' > $LED_BLUE_CURRENT
	echo '0' > $LED_RED
	echo '0' > $LED_RED_CURRENT

	echo '0' > $LED2_BLUE
	echo '0' > $LED2_BLUE_CURRENT
	echo '0' > $LED2_RED
	echo '0' > $LED2_RED_CURRENT

	exec /init
fi

# vol-, boot CWM recovery
if [ -s /temp/keycheck_down -o -e /cache/recovery/boot ]
then

	# Show green led
	echo '96' > $LED3_GREEN
	echo '96' > $LED3_GREEN_CURRENT
	echo '96' > $LED_GREEN
	echo '96' > $LED_GREEN_CURRENT
	echo '96' > $LED2_GREEN
	echo '96' > $LED2_GREEN_CURRENT


	rm /temp/keycheck_down
	rm /cache/recovery/boot
	recovery_ramdisk
	cd /
	tar xf /temp/cwm.tar
	sync
	sleep 1

	# turn off leds
	echo '0' > $LED3_GREEN
	echo '0' > $LED3_GREEN_CURRENT
	echo '0' > $LED_GREEN
	echo '0' > $LED_GREEN_CURRENT
	echo '0' > $LED2_GREEN
	echo '0' > $LED2_GREEN_CURRENT

	exec /init
fi

	android_ramdisk
	cd /
	tar xf /temp/ramdisk.tar
	sync
	chroot / /init
