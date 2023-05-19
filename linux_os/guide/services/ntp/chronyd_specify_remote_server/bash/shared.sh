# platform = multi_platform_all

{{{ bash_instantiate_variables("var_multiple_time_servers") }}}

config_file="{{{ chrony_conf_path }}}"

if ! grep -q '^[[:space:]]*\(server\|pool\)[[:space:]]\+[[:graph:]]\+' "$config_file" ; then
  {{{ bash_ensure_there_are_servers_in_ntp_compatible_config_file("$config_file", "$var_multiple_time_servers") | indent(2) }}}
fi
