# platform = multi_platform_rhel,multi_platform_ol,multi_platform_fedora,multi_platform_rhv,multi_platform_sle,multi_platform_ubuntu

if LC_ALL=C grep -iw ^log_file /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
    FILE="/var/log/audit/audit.log"
fi

{{% if product not in ["ol8"] and "rhel" not in product %}}
if LC_ALL=C grep -m 1 -q ^log_group /etc/audit/auditd.conf; then
  GROUP=$(awk -F "=" '/log_group/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
  if ! [ "${GROUP}" == 'root' ] ; then
    chmod 0640 $FILE
    chmod 0440 $FILE.*
  else
    chmod 0600 $FILE
    chmod 0400 $FILE.*
  fi
else
  chmod 0600 $FILE
  chmod 0400 $FILE.*
fi
{{% else %}}
chmod 0600 $FILE
{{% endif %}}
