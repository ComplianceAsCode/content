if [ -e /etc/audit/auditd.conf ]; then
	grep "^log_file" /etc/audit/auditd.conf | sed s/^[^\/]*// | xargs setfacl --remove-all
elif [ -e /etc/auditd.conf ]; then
	grep "^log_file" /etc/auditd.conf | sed s/^[^\/]*// | xargs setfacl --remove-all
fi
