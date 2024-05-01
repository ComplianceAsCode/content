# platform = multi_platform_ubuntu

if LC_ALL=C grep -iw log_file /etc/audit/auditd.conf; then
  FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
  FILE="/var/log/audit/audit.log"
fi

{{{ bash_auditd_config_set("log_group", "root") }}}

chgrp root $FILE
