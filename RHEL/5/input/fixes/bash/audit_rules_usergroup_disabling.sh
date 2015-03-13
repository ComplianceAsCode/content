if [ -e /etc/audit/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit/audit.rules"
elif [ -e /etc/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit.rules"
else
	exit
fi

if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w /usr/bin/passwd"`" = "0" ]; then
	echo "-w /usr/bin/passwd -p x -k audit_account_changes" >>${AUDIT_RULES_FILE}
elif [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w /usr/bin/passwd -p [wa]*x"`" = "0" ]; then
	if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w /usr/bin/passwd -p "`" = "0" ]; then
		sed -i "s/\(-w \/usr\/bin\/passwd\)/\1 -p x/" ${AUDIT_RULES_FILE}
	else
		sed -i "s/\(-w \/usr\/bin\/passwd -p \)/\1x/" ${AUDIT_RULES_FILE}
	fi
fi
service auditd restart 1>/dev/null
