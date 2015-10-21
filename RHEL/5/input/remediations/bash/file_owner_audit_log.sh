if [ -e /etc/audit/auditd.conf ]; then
	grep ^log_file /etc/audit/auditd.conf | awk '{ print $3 }' | xargs chown root
if [ -e /etc/auditd.conf ]; then
	grep ^log_file /etc/auditd.conf | awk '{ print $3 }' | xargs chown root
fi
