# platform = multi_platform_sle

LOCAL_TZ=`timedatectl status | grep -c "RTC in local TZ: yes"`

if [ $LOCAL_TZ -eq 1 ]; then
	timedatectl set-local-rtc 0 --adjust-system-clock
fi

