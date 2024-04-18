# platform = multi_platform_all

{{{ bash_instantiate_variables("var_auditd_space_left_percentage") }}}

grep -q "^space_left[[:space:]]*=.*$" /etc/audit/auditd.conf && \
  sed -i "s/^space_left[[:space:]]*=.*$/space_left = $var_auditd_space_left_percentage%/g" /etc/audit/auditd.conf || \
  echo "space_left = $var_auditd_space_left_percentage%" >> /etc/audit/auditd.conf
