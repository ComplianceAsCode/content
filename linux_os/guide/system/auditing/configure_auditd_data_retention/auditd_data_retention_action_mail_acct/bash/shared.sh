# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_action_mail_acct

AUDITCONFIG=/etc/audit/auditd.conf

grep -q ^action_mail_acct $AUDITCONFIG && \
  sed -i 's/^action_mail_acct.*/action_mail_acct = '"$var_auditd_action_mail_acct"'/g' $AUDITCONFIG
if ! [ $? -eq 0 ]; then
  echo "action_mail_acct = $var_auditd_action_mail_acct" >> $AUDITCONFIG
fi
