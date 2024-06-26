# platform = Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_sle
# reboot = false
# strategy = enable
# complexity = low
# disruption = low
if {{{ bash_package_installed("chrony") }}} ; then
    if ! /usr/sbin/pidof ntpd ; then
        {{{ bash_service_command("enable", "chronyd") | indent(8) }}}
    fi
elif {{{ bash_package_installed("ntp") }}} ; then
    {{{ bash_service_command("enable", "ntpd") | indent(4) }}}
else
    {{{ bash_package_install("chrony") | indent(4) }}}
    {{{ bash_service_command("enable", "chronyd") | indent(4) }}}
fi
