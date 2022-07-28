# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_pam_faillock_enable() }}}
AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    regex="^\s*audit"
    line="audit"
    if ! grep -q $regex $FAILLOCK_CONF; then
        echo $line >> $FAILLOCK_CONF
    fi
    for pam_file in "${AUTH_FILES[@]}"
    do
        {{{ bash_remove_pam_module_option_configuration("$pam_file",'auth','','pam_faillock.so', 'audit' ) | indent(8) }}}
    done
else
    for pam_file in "${AUTH_FILES[@]}"
    do
        if ! grep -qE '^\s*auth.*pam_faillock.so preauth.*audit' "$pam_file"; then
            sed -i --follow-symlinks 's/^\s*auth.*required.*pam_faillock.so.*preauth/ s/$/ audit/' "$pam_file"
        fi
    done
fi
