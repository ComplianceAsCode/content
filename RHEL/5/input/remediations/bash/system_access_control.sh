if [ ! -e /etc/hosts.allow ]; then
	>/etc/hosts.allow
	chmod 644 /etc/hosts.allow
	chown root:root /etc/hosts.allow
fi
if [ ! -e /etc/hosts.deny ]; then
	>/etc/hosts.deny
	chmod 644 /etc/hosts.deny
	chown root:root /etc/hosts.deny
fi
if [ ! -e /var/log/host.access ]; then
	>/var/log/host.access
	chmod 640 /var/log/host.access
	chown root:root /var/log/host.access
fi
if [ $(grep -c "ALL: ALL" /etc/hosts.deny) = 0 ]; then
	echo 'ALL: ALL: spawn /bin/echo Access denied on $(/bin/date) from %a for access to %d \(pid %p\)>>/var/log/host.access' | tee -a /etc/hosts.deny &>/dev/null
fi
