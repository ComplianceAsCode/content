# platform = multi_platform_fedora,Red Hat Enterprise Linux 7

{{{ bash_instantiate_variables("var_multiple_time_servers") }}}

config_file="/etc/ntp.conf"

if ! grep -q '^[\s]*(?:server|pool)[\s]+[\w]+' "$config_file" ; then
          {{{ bash_ensure_there_are_servers_in_ntp_compatible_config_file("$config_file", "$var_multiple_time_servers") | indent(2) }}}
fi
