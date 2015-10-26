if [ -e /etc/audit/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit/audit.rules"
	AUDIT_TAG="-k audit_time_rules"
elif [ -e /etc/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit.rules"
	AUDIT_TAG=""
else
	exit
fi

if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c ' -S stime '`" = "0" ]; then
	if [ "`uname -p`" != "x86_64" ]; then
		echo "-a exit,always -F arch=b32 -S stime ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
		# stime is not supported on 64-bit.
	fi
fi
service auditd restart 1>/dev/null
