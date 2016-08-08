if [ -e /etc/audit/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit/audit.rules"
elif [ -e /etc/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit.rules"
else
	exit
fi
for FILE in /var/log/faillog /var/log/lastlog; do
	if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE}"`" = "0" ]; then
		echo "-w ${FILE} -p wa -k audit_login_events" >>${AUDIT_RULES_FILE}
	elif [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p [x]*\(wa\|aw\)"`" = "0" ]; then
		SED_FILE="$(echo ${FILE} | sed 's/\//\\\//g')"
		if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p "`" = "0" ]; then
			sed -i "s/\(-w ${SED_FILE}\)/\1 -p wa/" ${AUDIT_RULES_FILE}
		else
			if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p [xa]*w"`" = "0" ]; then
				sed -i "s/\(-w ${SED_FILE} -p \)/\1w/" ${AUDIT_RULES_FILE}
			fi
			if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p [xw]*a"`" = "0" ]; then
				sed -i "s/\(-w ${SED_FILE} -p \)/\1a/" ${AUDIT_RULES_FILE}
			fi
		fi
	fi
done
service auditd restart 1>/dev/null
