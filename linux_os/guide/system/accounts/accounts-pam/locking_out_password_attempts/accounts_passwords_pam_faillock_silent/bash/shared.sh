# platform = multi_platform_all

{{{ bash_pam_faillock_enable() }}}

AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    regex="^\s*silent"
    line="silent"
    if ! grep -q $regex $FAILLOCK_CONF; then
        echo $line >> $FAILLOCK_CONF
    fi
else
    for pam_file in "${AUTH_FILES[@]}"
    do
        if ! grep -qE '^\s*auth.*pam_faillock\.so\s*preauth.*silent' "$pam_file"; then
            sed -i --follow-symlinks '/^\s*auth.*pam_faillock\.so.*preauth/ s/$/ silent/' "$pam_file"
        fi
    done
fi
