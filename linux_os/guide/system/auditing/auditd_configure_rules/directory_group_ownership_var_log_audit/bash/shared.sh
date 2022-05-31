# platform = multi_platform_all

if LC_ALL=C grep -m 1 -q ^log_group /etc/audit/auditd.conf; then
  GROUP=$(awk -F "=" '/log_group/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
  GROUP=root
fi
if LC_ALL=C grep -iw ^log_file /etc/audit/auditd.conf; then
  DIR=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ' | rev | cut -d"/" -f2- | rev)
else
  DIR="/var/log/audit"
fi

{{% if product == "ol8" %}}
GROUP="root"
{{% endif %}}
find ${DIR} -type d -exec chgrp ${GROUP} {} \;
