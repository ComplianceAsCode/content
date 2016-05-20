# platform = SUSE Enterprise 12
#
# Set runtime for kernel.randomize_va_space
#
sysctl -q -n -w kernel.randomize_va_space=2

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' 'CCENUM'
