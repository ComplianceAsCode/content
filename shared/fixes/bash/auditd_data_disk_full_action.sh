# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_disk_full_action

#
# If disk_full_action present in /etc/audit/auditd.conf, change value
# to var_auditd_disk_full_action, else
# add "disk_full_action = $var_auditd_disk_full_action" to /etc/audit/auditd.conf
#

if grep --silent ^disk_full_action /etc/audit/auditd.conf ; then
        sed -i 's/^disk_full_action.*/disk_full_action = '"$var_auditd_disk_full_action"'/g' /etc/audit/auditd.conf
else
        echo -e "\n# Set disk_full_action to $var_auditd_disk_full_action per security requirements" >> /etc/audit/auditd.conf
        echo "disk_full_action = $var_auditd_disk_full_action" >> /etc/audit/auditd.conf
fi
