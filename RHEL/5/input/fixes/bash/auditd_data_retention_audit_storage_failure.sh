if [ -e /etc/audit/auditd.conf ]; then
	AUDITD_CONF_FILE="/etc/audit/auditd.conf"
elif [ -e /etc/auditd.conf ]; then
	AUDITD_CONF_FILE="/etc/auditd.conf"
else
	exit
fi

if [ "$(grep -v "#" ${AUDITD_CONF_FILE} | grep -c space_left_action)" != "0" ]; then
	sed -i 's/space_left_action.*/space_left_action = syslog/' ${AUDITD_CONF_FILE}
else
	echo "space_left_action = syslog">>${AUDITD_CONF_FILE}
fi
