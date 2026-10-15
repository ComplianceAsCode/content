# platform = multi_platform_all

{{% if 'debian' in product or 'sle' in product or 'slmicro' in product %}}
{{{ bash_ensure_pam_module_option("/etc/pam.d/common-password", "password", "sufficient", "pam_unix.so", "use_authtok") }}}
{{% else %}}
{{{ bash_ensure_pam_module_option("/etc/pam.d/system-auth", "password", "sufficient", "pam_unix.so", "use_authtok") }}}
{{{ bash_ensure_pam_module_option("/etc/pam.d/password-auth", "password", "sufficient", "pam_unix.so", "use_authtok") }}}
{{% endif %}}
