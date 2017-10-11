# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_space_left

grep -q ^space_left /etc/audit/auditd.conf && \
  sed -i "s/space_left.*/space_left = $var_auditd_space_left/g" /etc/audit/auditd.conf
if ! [ $? -eq 0 ]; then
    echo "space_left = $var_auditd_space_left" >> /etc/audit/auditd.conf
fi
