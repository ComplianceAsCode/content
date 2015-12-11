. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_disk_error_action

if [ -e /etc/audit/auditd.conf ]; then
	AUDITD_CONF_FILE="/etc/audit/auditd.conf"
elif [ -e /etc/auditd.conf ]; then
	AUDITD_CONF_FILE="/etc/auditd.conf"
else
	exit
fi

grep -q ^disk_error_action ${AUDITD_CONF_FILE} && \
  sed -i "s/disk_error_action.*/disk_error_action = $var_auditd_disk_error_action/g" ${AUDITD_CONF_FILE}
if ! [ $? -eq 0 ]; then
    echo "disk_error_action = $var_auditd_disk_error_action" >> ${AUDITD_CONF_FILE}
fi
grep -q ^disk_full_action ${AUDITD_CONF_FILE} && \
  sed -i "s/disk_full_action.*/disk_full_action = $var_auditd_disk_error_action/g" ${AUDITD_CONF_FILE}
if ! [ $? -eq 0 ]; then
    echo "disk_full_action = $var_auditd_disk_error_action" >> ${AUDITD_CONF_FILE}
fi
