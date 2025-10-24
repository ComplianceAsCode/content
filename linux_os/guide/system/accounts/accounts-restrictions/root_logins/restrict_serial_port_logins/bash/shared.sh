# platform = multi_platform_all
sed -i '/ttyS/d' /etc/securetty

{{% if product == "sle16" %}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/login', 'auth', 'required', 'pam_securetty.so', 'noconsole', '', '') }}}
{{% endif %}}
