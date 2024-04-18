# platform = multi_platform_all

{{{ bash_instantiate_variables("var_auditd_admin_space_left_percentage") }}}

grep -q "^admin_space_left[[:space:]]*=.*$" /etc/audit/auditd.conf && \
  sed -i "s/^admin_space_left[[:space:]]*=.*$/admin_space_left = $var_auditd_admin_space_left_percentage%/g" /etc/audit/auditd.conf || \
  echo "admin_space_left = $var_auditd_admin_space_left_percentage%" >> /etc/audit/auditd.conf
