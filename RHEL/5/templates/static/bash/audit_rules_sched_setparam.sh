if [ -e /etc/audit/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit/audit.rules"
	AUDIT_TAG="-k set_scheduler_parameters"
elif [ -e /etc/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit.rules"
	AUDIT_TAG=""
else
	exit
fi

# check for realtime capabilities
if [ `lsmod | grep -ic jiffies` = 0 ]; then
	if [ "`uname -p`" != "x86_64" ]; then
		echo "-a exit,always -F arch=b32 -S sched_setparam ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
	else
		echo "-a exit,always -F arch=b64 -S sched_setparam ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
	fi
fi
service auditd restart 1>/dev/null
