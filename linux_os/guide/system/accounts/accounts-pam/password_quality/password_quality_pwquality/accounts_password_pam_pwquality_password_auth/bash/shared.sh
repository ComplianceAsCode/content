# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_rhel

{{{ bash_ensure_pam_module_configuration('/etc/pam.d/password-auth', 'password', 'requisite', 'pam_pwquality.so', '', '', '^account.*required.*pam_permit.so') }}}
