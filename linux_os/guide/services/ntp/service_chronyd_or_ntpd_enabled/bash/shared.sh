# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions

if rpm -q --quiet chrony ; then
    if ! /usr/sbin/pidof ntpd ; then
        service_command enable chronyd
    fi
elif rpm -q --quiet ntp- ; then
    service_command enable ntpd
else
    {{{ bash_package_install("chrony") | indent(4) }}}
    service_command enable chronyd
fi
