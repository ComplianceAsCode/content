# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_rhel,multi_platform_ol,multi_platform_almalinux

{{{ bash_ensure_pam_module_configuration('/etc/pam.d/password-auth', 'password', 'requisite', 'pam_pwquality.so', '', '', '^account.*required.*pam_permit\.so') }}}
