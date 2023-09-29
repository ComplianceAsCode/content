# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_networkmanager_dns_mode") }}}

{{{ bash_ini_file_set("/etc/NetworkManager/NetworkManager.conf", "main", "dns", "$var_networkmanager_dns_mode") }}}
