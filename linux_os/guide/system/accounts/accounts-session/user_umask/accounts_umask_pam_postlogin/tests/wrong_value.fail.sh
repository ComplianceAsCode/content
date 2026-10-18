#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

{{{ bash_ensure_pam_module_configuration('/etc/pam.d/postlogin', 'session', 'optional', 'pam_umask.so', 'umask', '0022', 'BOF') }}}
