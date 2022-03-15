# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

if [ -f /usr/bin/authselect ]; then
    {{{ bash_enable_pam_faillock_with_authselect() }}}
fi

{{{ bash_set_faillock_option("even_deny_root", "") }}}
