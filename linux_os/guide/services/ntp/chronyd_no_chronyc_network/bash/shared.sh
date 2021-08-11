# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Include source function library
. /usr/share/scap-security-guide/remediation_functions

"/etc/chrony.conf", '^cmdport', 0, '@CCENUM@', '%s %s') }}}
