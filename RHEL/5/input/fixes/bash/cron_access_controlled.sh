if [ ! -e [/etc/cron.allow ]; then
	> /etc/cron.allow
	chown root:root /etc/cron.allow
	chmod 0600 /etc/cron.allow
fi
if [ ! -e [/etc/cron.deny ]; then
	SYS_USER=$(cat /etc/passwd | while read entry; do if [ "$(echo ${entry} | cut -d: -f3)" -lt "500" ]; then echo ${entry} | cut -d: -f1 ; fi; done)
	for USER in `echo $SYS_USER`; do
		if [ $(grep -c "^${USER}$" /etc/cron.deny) = 0 ]; then
			echo ${USER} | tee -a /etc/cron.deny &>/dev/null
		fi
	done
	chown root:root /etc/cron.deny
	chmod 0600 /etc/cron.deny
fi
