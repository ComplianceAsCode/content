# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Oracle Linux 7,multi_platform_sle

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables("sshd_approved_macs") }}}

replace_or_append '/etc/ssh/sshd_config' '^MACs' "$sshd_approved_macs" '@CCENUM@' '%s %s'
