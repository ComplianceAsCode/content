# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_max_log_file

AUDITCONFIG=/etc/audit/auditd.conf

grep -q ^max_log_file $AUDITCONFIG && \
  sed -i 's/^max_log_file.*/max_log_file = '"$var_auditd_max_log_file"'/g' $AUDITCONFIG
if ! [ $? -eq 0 ]; then
  echo "max_log_file = $var_auditd_max_log_file" >> $AUDITCONFIG
fi
