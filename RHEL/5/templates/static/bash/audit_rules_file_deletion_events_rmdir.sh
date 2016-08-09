if [ -e /etc/audit/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit/audit.rules"
	AUDIT_TAG="-k delete"
elif [ -e /etc/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit.rules"
	AUDIT_TAG=""
else
	exit
fi

if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c ' -S rmdir '`" = "0" ]; then
	if [ "`uname -p`" != "x86_64" ]; then
		echo "-a exit,always -F arch=b32 -S rmdir ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
	else
		echo "-a exit,always -F arch=b64 -S rmdir ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
	fi
fi
service auditd restart 1>/dev/null
