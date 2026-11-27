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

function add_audit_rule()
{
    local PRIV_CMD="$1"
    local OTHER_FILTERS="-F path=$PRIV_CMD -F perm=x"
    # Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{% if product in ["fedora", "rhel10"] %}}
    [ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")
    for ARCH in "${RULE_ARCHS[@]}" ; do
        ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
        {{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") | indent(4) }}}
        {{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") | indent(4) }}}
    done
{{% else %}}
    ACTION_ARCH_FILTERS="-a always,exit"
    {{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") | indent(4) }}}
    {{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") | indent(4) }}}
{{% endif %}}

}

PRIV_CMD_DRACUT_EXCLUSION=(-not -path "/var/tmp/dracut*")
PRIV_CMD_SYSROOT_EXCLUSION=(-not -path "/sysroot/*")

if {{{ bash_bootc_build() }}} ; then
  priv_cmds=$(find / -xdev -perm /6000 -type f \
    "${PRIV_CMD_SYSROOT_EXCLUSION[@]}" "${PRIV_CMD_DRACUT_EXCLUSION[@]}" 2>/dev/null)
else
  priv_cmds=""
  FILTER_NODEV=$(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,)
  PARTITIONS=$(findmnt -n -l -k -it "$FILTER_NODEV" | grep -Pv "noexec|nosuid|/proc($|/.*$)" | awk '{ print $1 }')
  for PARTITION in $PARTITIONS; do
    priv_cmds+=$'\n'"$(find "${PARTITION}" -xdev -perm /6000 -type f \
      "${PRIV_CMD_DRACUT_EXCLUSION[@]}" 2>/dev/null)"
  done
  # Offline/image-build fallback: the live mount table isn't the image's.
  if [ -z "$(printf '%s' "$priv_cmds" | tr -d '[:space:]')" ]; then
    priv_cmds=$(find / -xdev -perm /6000 -type f \
      "${PRIV_CMD_SYSROOT_EXCLUSION[@]}" "${PRIV_CMD_DRACUT_EXCLUSION[@]}" 2>/dev/null)
  fi
fi

for PRIV_CMD in $priv_cmds; do
  [ -n "$PRIV_CMD" ] && add_audit_rule "$PRIV_CMD"
done
