# platform = multi_platform_sle,multi_platform_ubuntu
{{% if product in ["ubuntu1604", "ubuntu1804", "ubuntu2004"] %}}
{{{ bash_ensure_pam_module_options('/etc/pam.d/common-auth', 'auth', '[success=2 default=ignore]', 'pam_pkcs11.so', '', '', '') }}}
{{% else %}}
{{{ bash_ensure_pam_module_options('/etc/pam.d/common-auth', 'auth','sufficient', 'pam_pkcs11.so', '', '', '') }}}
{{% endif %}}
