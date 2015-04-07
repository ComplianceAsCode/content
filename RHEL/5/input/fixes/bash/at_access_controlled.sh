if [ ! -e [/etc/at.allow ]; then
	> /etc/at.allow
	chown root:root /etc/at.allow
	chmod 0600 /etc/at.allow
fi
if [ ! -e [/etc/at.deny ]; then
	SYS_USER=$(cat /etc/passwd | while read entry; do if [ "$(echo ${entry} | cut -d: -f3)" -lt "500" ]; then echo ${entry} | cut -d: -f1 ; fi; done)
	for USER in `echo $SYS_USER`; do
		if [ $(grep -c "^${USER}$" /etc/at.deny) = 0 ]; then
			echo ${USER} | tee -a /etc/at.deny &>/dev/null
		fi
	done
	chown root:root /etc/at.deny
	chmod 0600 /etc/at.deny
fi
