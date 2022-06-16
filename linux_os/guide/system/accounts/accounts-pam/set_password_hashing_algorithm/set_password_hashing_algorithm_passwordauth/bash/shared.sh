# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_rhv,multi_platform_ol

{{{ bash_provide_pam_module_options('/etc/pam.d/password-auth', 'password', 'sufficient', 'pam_unix.so', 'sha512', '', '') }}}
