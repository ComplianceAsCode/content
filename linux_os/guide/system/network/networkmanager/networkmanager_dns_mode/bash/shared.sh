# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_instantiate_variables("var_networkmanager_dns_mode") }}}

{{{ bash_ini_file_set("/etc/NetworkManager/NetworkManager.conf", "main", "dns", "$var_networkmanager_dns_mode") }}}

if {{{ bash_not_bootc_build() }}} ; then
    systemctl reload NetworkManager
fi
