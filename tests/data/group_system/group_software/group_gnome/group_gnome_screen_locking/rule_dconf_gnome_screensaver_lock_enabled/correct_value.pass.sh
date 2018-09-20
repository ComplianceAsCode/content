#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

yum -y install dconf

# It is ok if string is not found in any file
file=$(grep -R "lock-enabled" /etc/dconf/db/local.d) || true
if [ -n "$file" ] ; then
	sed -i "s/^lock-enabled=.*/lock-enabled=true/g" $file
else
	echo "[org/gnome/desktop/screensaver]" > /etc/dconf/db/local.d/00-security-settings
	echo "lock-enabled=true" >> /etc/dconf/db/local.d/00-security-settings
fi

lockfile=$(grep -R "lock-enabled" /etc/dconf/db/local.d/locks) || true
if [ -z "$file" ] ; then
    mkdir -p /etc/dconf/db/local.d/locks
	echo "/org/gnome/desktop/screensaver/lock-enabled" >> /etc/dconf/db/local.d/locks/00-security-settings-lock
fi
