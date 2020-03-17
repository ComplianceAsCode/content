# platform = multi_platform_all
. /usr/share/scap-security-guide/remediation_functions
populate var_multiple_time_servers

config_file="/etc/chrony.conf"

if ! grep -q '^[\s]*server[\s]+[\w]+' "$config_file" ; then
  {{{ bash_ensure_there_are_servers_in_ntp_compatible_config_file("$config_file", "$var_multiple_time_servers") | indent(2) }}}
fi
