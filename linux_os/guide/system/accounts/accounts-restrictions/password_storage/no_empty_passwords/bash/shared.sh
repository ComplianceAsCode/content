# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium
SYSTEM_AUTH="/etc/pam.d/system-auth"
PASSWORD_AUTH="/etc/pam.d/password-auth"

if [ -f /usr/bin/authselect ]; then
    if authselect check; then
        authselect enable-feature without-nullok
        authselect apply-changes
    else
        echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because the authselect profile is not intact.
It is not recommended to manually edit the PAM files when authselect is available
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        false
    fi
else
    sed --follow-symlinks -i 's/\<nullok\>//g' $SYSTEM_AUTH
    sed --follow-symlinks -i 's/\<nullok\>//g' $PASSWORD_AUTH
fi
