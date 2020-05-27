# platform = multi_platform_all

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables("var_ssh_client_rekey_limit_size", "var_ssh_client_rekey_limit_time") }}}

{{{ set_config_file(path="/etc/ssh/ssh_config.d/02-rekey-limit.conf", parameter="RekeyLimit", value='$var_ssh_client_rekey_limit_size $var_ssh_client_rekey_limit_time', create=true, insert_before="", insert_after="", insensitive=false, separator=" ", separator_regex="\s\+", prefix_regex="^\s*") }}}
