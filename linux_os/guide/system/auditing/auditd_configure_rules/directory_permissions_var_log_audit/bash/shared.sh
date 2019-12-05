# platform = Red Hat Virtualization 4,multi_platform_rhel

if LC_ALL=C grep -m 1 -q ^log_group /etc/audit/auditd.conf; then
  GROUP=$(awk -F "=" '/log_group/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
  if ! [ "${GROUP}" == 'root' ] ; then
    chmod 0750 /var/log/audit
  else
    chmod 0700 /var/log/audit
  fi
else
  chmod 0700 /var/log/audit
fi
