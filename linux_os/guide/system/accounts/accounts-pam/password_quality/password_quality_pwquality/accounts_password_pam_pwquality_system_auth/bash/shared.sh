# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_rhel,multi_platform_ol,multi_platform_almalinux

{{% set pam_pwquality_control = "required" if "rhel" in families else "requisite" %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', pam_pwquality_control, 'pam_pwquality.so', '', '', '^account.*required.*pam_permit\.so') }}}
