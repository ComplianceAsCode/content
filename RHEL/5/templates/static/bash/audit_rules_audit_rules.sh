if [ -e /etc/audit/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit/audit.rules"
elif [ -e /etc/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit.rules"
else
	exit
fi

if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${AUDIT_RULES_FILE}"`" = "0" ]; then
	echo "-w ${AUDIT_RULES_FILE} -p wa -k audit_rules_changes" >>${AUDIT_RULES_FILE}
elif [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${AUDIT_RULES_FILE} -p [x]*\(wa\|aw\)"`" = "0" ]; then
	if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${AUDIT_RULES_FILE} -p "`" = "0" ]; then
		sed -i "s/\(-w ${AUDIT_RULES_FILE}\)/\1 -p wa/" ${AUDIT_RULES_FILE}
	else
		if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${AUDIT_RULES_FILE} -p [xa]*w"`" = "0" ]; then
			sed -i "s/\(-w ${AUDIT_RULES_FILE} -p \)/\1w/" ${AUDIT_RULES_FILE}
		fi
		if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${AUDIT_RULES_FILE} -p [xw]*a"`" = "0" ]; then
			sed -i "s/\(-w ${AUDIT_RULES_FILE} -p \)/\1a/" ${AUDIT_RULES_FILE}
		fi
	fi
fi
service auditd restart 1>/dev/null
