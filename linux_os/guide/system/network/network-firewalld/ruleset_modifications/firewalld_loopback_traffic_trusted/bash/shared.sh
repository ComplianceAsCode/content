# platform = multi_platform_all
# reboot = false
# complexity = low
# strategy = configure
# disruption = low

{{{ bash_package_install("firewalld") }}}

if {{{ in_chrooted_environment }}}; then
    firewall-offline-cmd --zone=trusted --add-interface=lo
else
    firewall-cmd --permanent --zone=trusted --add-interface=lo
    firewall-cmd --reload
fi
