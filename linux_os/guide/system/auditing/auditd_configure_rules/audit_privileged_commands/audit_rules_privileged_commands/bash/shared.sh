# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

ACTION_ARCH_FILTERS="-a always,exit"
AUID_FILTERS="-F auid>={{{ auid }}} -F auid!=unset"
SYSCALL=""
KEY="privileged"
SYSCALL_GROUPING=""

FILTER_NODEV=$(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,)
PARTITIONS=$(findmnt -n -l -k -it $FILTER_NODEV | grep -Pv "noexec|nosuid|/proc($|/.*$)" | awk '{ print $1 }')
for PARTITION in $PARTITIONS; do
  PRIV_CMDS=$(find "${PARTITION}" -xdev -perm /6000 -type f 2>/dev/null)
  for PRIV_CMD in $PRIV_CMDS; do
    OTHER_FILTERS="-F path=$PRIV_CMD -F perm=x"
    # Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
    {{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") | indent(4) }}}
    {{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") | indent(4) }}}
  done
done
