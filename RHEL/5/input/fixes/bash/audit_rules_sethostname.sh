if [ -e /etc/audit/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit/audit.rules"
	AUDIT_TAG="-k set_hostname"
elif [ -e /etc/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit.rules"
	AUDIT_TAG=""
else
	exit
fi

if [ "`uname -p`" != "x86_64" ]; then
	echo "-a exit,always -F arch=b32 -S sethostname ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
else
	echo "-a exit,always -F arch=b64 -S sethostname ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
fi
service auditd restart 1>/dev/null
