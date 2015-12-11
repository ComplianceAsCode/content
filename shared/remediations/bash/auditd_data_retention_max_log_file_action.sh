# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_max_log_file_action

AUDITCONFIG=/etc/audit/auditd.conf

grep -q ^max_log_file_action $AUDITCONFIG && \
  sed -i 's/^max_log_file_action.*/max_log_file_action = '"$var_auditd_max_log_file_action"'/g' $AUDITCONFIG
if ! [ $? -eq 0 ]; then
  echo "max_log_file_action = $var_auditd_max_log_file_action" >> $AUDITCONFIG
fi
