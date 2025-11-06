# platform = multi_platform_sle,multi_platform_ubuntu

{{% if product in ['sle15', 'sle16'] %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/common-password', 'password', 'requisite', 'pam_pwquality.so', '', '', 'BOF') }}}
{{% else %}}
{{{ bash_pam_pwquality_enable() }}}
{{% endif %}}
