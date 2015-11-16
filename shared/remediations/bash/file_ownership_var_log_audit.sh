# platform = multi_platform_rhel

if `grep -q ^log_group /etc/audit/auditd.conf` ; then
  GROUP=$(awk -F "=" '/log_group/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
  if ! [ "${GROUP}" == 'root' ] ; then
    chown root.${GROUP} /var/log/audit
    chown root.${GROUP} /var/log/audit/audit.log*
  else
    chown root.root /var/log/audit
    chown root.root /var/log/audit/audit.log*
  fi
else
  chown root.root /var/log/audit
  chown root.root /var/log/audit/audit.log*
fi
