source ./templates/support.sh
populate var_auditd_space_left_action

grep -q ^space_left_action /etc/audit/auditd.conf && \
  sed -i "s/space_left_action.*/space_left_action = $var_auditd_space_left_action/g" /etc/audit/auditd.conf
if ! [ $? -eq 0 ]; then
    echo "space_left_action = $var_auditd_space_left_action" >> /etc/audit/auditd.conf
fi
