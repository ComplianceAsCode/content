# platform = Red Hat Enterprise Linux 7, multi_platform_fedora

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/systemd/system.conf' '^CtrlAltDelBurstAction=' 'none' '@CCENUM@' '%s=%s'
