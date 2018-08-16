# platform = multi_platform_rhel
find /home -maxdepth 2 -type f -name .rhosts -exec rm -f '{}' \;

if [ -f /etc/hosts.equiv ]; then
	/bin/rm -f /etc/hosts.equiv
fi
