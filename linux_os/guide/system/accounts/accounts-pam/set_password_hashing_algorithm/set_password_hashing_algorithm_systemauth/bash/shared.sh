# platform = multi_platform_all

{{% if product in ["sle15", "sle12"] -%}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/common-password', 'password', 'required', 'pam_unix.so', 'sha512', '', '') }}}
{{%- else -%}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', 'sufficient', 'pam_unix.so', 'sha512', '', '') }}}
{{%- endif %}}
