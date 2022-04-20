# platform = multi_platform_all

if LC_ALL=C grep -m 1 -q ^log_group /etc/audit/auditd.conf; then
  GROUP=$(awk -F "=" '/log_group/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
  GROUP=root
fi
find /var/log/audit -type d -exec chgrp ${GROUP} {} \;
