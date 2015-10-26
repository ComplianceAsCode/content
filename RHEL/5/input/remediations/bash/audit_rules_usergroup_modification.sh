if [ -e /etc/audit/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit/audit.rules"
elif [ -e /etc/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit.rules"
else
	exit
fi

for FILE in /usr/sbin/usermod /usr/sbin/groupmod; do
	if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE}"`" = "0" ]; then
		echo "-w ${FILE} -p x -k audit_account_changes" >>${AUDIT_RULES_FILE}
	elif [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p [wa]*x"`" = "0" ]; then
		SED_FILE="$(echo ${FILE} | sed 's/\//\\\//g')"
		if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p "`" = "0" ]; then
			sed -i "s/\(-w ${SED_FILE}\)/\1 -p x/" ${AUDIT_RULES_FILE}
		else
			sed -i "s/\(-w ${SED_FILE} -p \)/\1x/" ${AUDIT_RULES_FILE}
		fi
	fi
done
for FILE in /etc/group /etc/passwd /etc/gshadow /etc/shadow; do
	if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE}"`" = "0" ]; then
		echo "-w ${FILE} -p w -k audit_account_changes" >>${AUDIT_RULES_FILE}
	elif [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p [xa]*w"`" = "0" ]; then
		SED_FILE="$(echo ${FILE} | sed 's/\//\\\//g')"
		if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p "`" = "0" ]; then
			sed -i "s/\(-w ${SED_FILE}\)/\1 -p w/" ${AUDIT_RULES_FILE}
		else
			sed -i "s/\(-w ${SED_FILE} -p \)/\1w/" ${AUDIT_RULES_FILE}
		fi
	fi
done
service auditd restart 1>/dev/null
