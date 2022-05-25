# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu

if LC_ALL=C grep -iw ^log_file /etc/audit/auditd.conf; then
  DIR=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ' | rev | cut -d"/" -f2- | rev)
else
  DIR="/var/log/audit"
fi

{{% if product not in ["ol8", "rhel8"] %}}
if LC_ALL=C grep -m 1 -q ^log_group /etc/audit/auditd.conf; then
  GROUP=$(awk -F "=" '/log_group/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
  if ! [ "${GROUP}" == 'root' ] ; then
    chmod 0750 $DIR
  else
    chmod 0700 $DIR
  fi
else
  chmod 0700 $DIR
fi
{{% else %}}
chmod 0700 $DIR
{{% endif %}}
