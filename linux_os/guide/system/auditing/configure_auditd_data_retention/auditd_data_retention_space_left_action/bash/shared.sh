# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_space_left_action

#
# If space_left_action present in /etc/audit/auditd.conf, change value
# to var_auditd_space_left_action, else
# add "space_left_action = $var_auditd_space_left_action" to /etc/audit/auditd.conf
#

if grep --silent ^space_left_action /etc/audit/auditd.conf ; then
        sed -i 's/^space_left_action.*/space_left_action = '"$var_auditd_space_left_action"'/g' /etc/audit/auditd.conf
else
        echo -e "\n# Set space_left_action to $var_auditd_space_left_action per security requirements" >> /etc/audit/auditd.conf
        echo "space_left_action = $var_auditd_space_left_action" >> /etc/audit/auditd.conf
fi
