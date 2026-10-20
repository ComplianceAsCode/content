#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

PAM_FILE_PATH="/etc/pam.d/postlogin"
if [ -f /usr/bin/authselect ]; then
    {{{ bash_ensure_pam_variables_and_authselect_profile('/etc/pam.d/postlogin') | indent(4) }}}
fi
sed -i '/pam_umask\.so/d' "$PAM_FILE_PATH"
if [ -f /usr/bin/authselect ]; then
    {{{ bash_apply_authselect_changes() | indent(4) }}}
fi
