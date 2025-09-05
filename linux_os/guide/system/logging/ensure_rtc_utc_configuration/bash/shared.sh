# platform = multi_platform_ubuntu

if timedatectl status | grep -i "time zone" | grep -iv 'UTC\|GMT'; then
    timedatectl set-timezone UTC
fi
