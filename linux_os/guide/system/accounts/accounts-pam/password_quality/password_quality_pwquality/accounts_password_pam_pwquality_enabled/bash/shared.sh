# platform = multi_platform_sle,multi_platform_ubuntu,multi_platform_debian

{{% if product in ['sle15', 'sle16'] or 'debian' in product %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/common-password', 'password', 'requisite', 'pam_pwquality.so', '', '', 'BOF') }}}
{{% else %}}
{{{ bash_pam_pwquality_enable() }}}
{{% endif %}}
