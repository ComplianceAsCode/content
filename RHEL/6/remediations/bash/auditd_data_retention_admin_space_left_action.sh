# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_admin_space_left_action

grep -q ^admin_space_left_action /etc/audit/auditd.conf && \
  sed -i "s/admin_space_left_action.*/admin_space_left_action = $var_auditd_admin_space_left_action/g" /etc/audit/auditd.conf
if ! [ $? -eq 0 ]; then
    echo "admin_space_left_action = $var_auditd_admin_space_left_action" >> /etc/audit/auditd.conf
fi
