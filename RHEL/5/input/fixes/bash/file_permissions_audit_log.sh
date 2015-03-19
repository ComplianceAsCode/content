if [ -e /etc/audit/auditd.conf ]; then
	grep ^log_file /etc/audit/auditd.conf | awk '{ print $3 }' | xargs chmod 640
elif [ -e /etc/auditd.conf ]; then
	grep ^log_file /etc/auditd.conf | awk '{ print $3 }' | xargs chmod 640
fi
