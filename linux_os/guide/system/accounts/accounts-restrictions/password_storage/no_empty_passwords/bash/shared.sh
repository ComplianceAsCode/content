# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle
SYSTEM_AUTH="/etc/pam.d/system-auth"
PASSWORD_AUTH="/etc/pam.d/password-auth"

if [ -f /usr/bin/authselect ]; then
    if [ $(authselect enable-feature without-nullok) ]; then
        authselect apply-changes
    else
        ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        authselect select $CURRENT_PROFILE --force
        for feature in $ENABLED_FEATURES without-nullok; do
            authselect enable-feature $feature;
        done
        authselect apply-changes
    fi
else
    sed --follow-symlinks -i 's/\<nullok\>//g' $SYSTEM_AUTH
    sed --follow-symlinks -i 's/\<nullok\>//g' $PASSWORD_AUTH
fi
