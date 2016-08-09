find /var/log -follow -type f ! -name wtmp 2>/dev/null | xargs chmod o-rwx,g-wx,u-x

# The following corrects the permission mask set for /var/log/rpmpkgs.
if [ -e /etc/cron.daily/rpm ]; then
	sed -i '/rpmpkgs/s/0644/0640/' /etc/cron.daily/rpm
fi
