#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

# Without a umask argument pam_umask falls back to UMASK from /etc/login.defs.
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/postlogin', 'session', 'optional', 'pam_umask.so', 'silent', '', 'BOF') }}}
{{{ bash_remove_pam_module_option_configuration('/etc/pam.d/postlogin', 'session', 'optional', 'pam_umask.so', 'umask') }}}
