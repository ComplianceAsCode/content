# platform = Red Hat Enterprise Linux 7
#
# Set runtime for kernel.randomize_va_space
#
sysctl -q -n -w kernel.randomize_va_space=2

# Include source function library.
. $SHARED_REMEDIATION_FUNCTIONS

replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '$CCENUM'
