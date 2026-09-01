# platform = multi_platform_all
sed -i '/ttyS/d' /etc/securetty

{{% if product in ['sle16', 'slmicro6'] %}}
{{{ bash_copy_distro_defaults("/usr/lib/pam.d/login", "/etc/pam.d/login") }}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/login', 'auth', 'required', 'pam_securetty.so', 'noconsole', '', '') }}}
{{% endif %}}
