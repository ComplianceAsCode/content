# platform = Red Hat Enterprise Linux 7
#
# Set runtime for SYSCTLVAR
#
/sbin/sysctl -q -n -w net.ipv6.conf.all.accept_source_route=0

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

#
# If SYSCTLVAR present in /etc/sysctl.conf, change value to "SYSCTLVAL"
#	else, add "SYSCTLVAR = SYSCTLVAL" to /etc/sysctl.conf
#
replace_or_append '/etc/sysctl.conf' '^net.ipv6.conf.all.accept_source_route' '0' '$CCENUM'
