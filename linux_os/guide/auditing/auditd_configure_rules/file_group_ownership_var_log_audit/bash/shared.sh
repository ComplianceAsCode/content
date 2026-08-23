# platform = multi_platform_all

if LC_ALL=C grep -iw log_file /etc/audit/auditd.conf; then
  FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
  FILE="/var/log/audit/audit.log"
fi

{{% if product == "ol8" %}}
chgrp root $FILE
{{% else %}}
if LC_ALL=C grep -m 1 -q ^log_group /etc/audit/auditd.conf; then
  GROUP=$(awk -F "=" '/log_group/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
    if ! [ "${GROUP}" == 'root' ]; then
      chgrp ${GROUP} $FILE*
    else
      chgrp root $FILE*
    fi
else
  chgrp root $FILE*
fi
{{% endif %}}

