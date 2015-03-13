if [ -e /etc/audit/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit/audit.rules"
	AUDIT_TAG="-k modules"
elif [ -e /etc/audit.rules ]; then
	AUDIT_RULES_FILE="/etc/audit.rules"
	AUDIT_TAG=""
else
	exit
fi

if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c ' -S init_module '`" = "0" ]; then
	if [ "`uname -p`" != "x86_64" ]; then
		echo "-a exit,always -F arch=b32 -S init_module ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
	else
		echo "-a exit,always -F arch=b64 -S init_module ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
	fi
fi
if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c ' -S delete_module '`" = "0" ]; then
	if [ "`uname -p`" != "x86_64" ]; then
		echo "-a exit,always -F arch=b32 -S delete_module ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
	else
		echo "-a exit,always -F arch=b64 -S delete_module ${AUDIT_TAG}" >>${AUDIT_RULES_FILE}
	fi
fi

for FILE in /sbin/insmod /sbin/rmmod /sbin/modprobe; do
	if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE}"`" = "0" ]; then
		echo "-w ${FILE} -p x -k modules" >>${AUDIT_RULES_FILE}
	elif [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p [wa]*x"`" = "0" ]; then
		SED_FILE="$(echo ${FILE} | sed 's/\//\\\//g')"
		if [ "`grep -v '#' ${AUDIT_RULES_FILE} | grep -c "\-w ${FILE} -p "`" = "0" ]; then
			sed -i "s/\(-w ${SED_FILE}\)/\1 -p x/" ${AUDIT_RULES_FILE}
		else
			sed -i "s/\(-w ${SED_FILE} -p \)/\1x/" ${AUDIT_RULES_FILE}
		fi
	fi
done
service auditd restart 1>/dev/null
