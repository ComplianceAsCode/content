# platform = Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol

{{{ bash_instantiate_variables("var_multiple_time_servers") }}}

config_file="/etc/ntp.conf"
/usr/sbin/pidof ntpd || config_file="{{{ chrony_conf_path }}}"

if ! grep -q ^server "$config_file" ; then
  {{{ bash_ensure_there_are_servers_in_ntp_compatible_config_file("$config_file", "$var_multiple_time_servers") | indent(2) }}}
fi
