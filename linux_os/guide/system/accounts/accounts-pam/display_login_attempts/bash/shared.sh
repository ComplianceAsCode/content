# platform = multi_platform_sle,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu

{{% if product in ["sle12", "sle15"] or "ubuntu" in product %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/login', 'session', 'required', 'pam_lastlog.so', 'showfailed', '', 'BOF') }}}
{{{ bash_remove_pam_module_option_configuration('/etc/pam.d/login', 'session', '', 'pam_lastlog.so', 'silent') }}}
{{% else %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/postlogin', 'session', 'required', 'pam_lastlog.so', 'showfailed', '', 'BOF') }}}
{{{ bash_remove_pam_module_option_configuration('/etc/pam.d/postlogin', 'session', '', 'pam_lastlog.so', 'silent') }}}
{{% endif %}}
