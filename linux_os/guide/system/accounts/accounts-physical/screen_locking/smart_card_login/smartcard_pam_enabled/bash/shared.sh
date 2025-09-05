# platform = multi_platform_sle,Ubuntu 20.04
{{% if 'ubuntu' in product %}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/common-auth', 'auth', '[success=2 default=ignore]', 'pam_pkcs11.so', '', '', '# here are the per-package modules') }}}
{{% else %}}
{{{ bash_ensure_pam_module_options('/etc/pam.d/common-auth', 'auth','sufficient', 'pam_pkcs11.so', '', '', '') }}}
{{% endif %}}
