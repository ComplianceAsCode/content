# platform = Red Hat Enterprise Linux 9

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_dir") }}}

[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
    ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
    OTHER_FILTERS="-F path=${var_accounts_passwords_pam_faillock_dir} -F perm=wa"
    AUID_FILTERS="-F auid>={{{ uid_min }}} -F auid!=unset"
    SYSCALL=""
    SYSCALL_GROUPING=""
    KEY="logins"

    {{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
    {{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
done
