# platform = multi_platform_sle,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu

{{% if product in ["sle12", "sle15"] or 'ubuntu' in product %}}
{{% set pam_lastlog_path = "/etc/pam.d/login" %}}
{{% else %}}
{{% set pam_lastlog_path = "/etc/pam.d/postlogin" %}}
{{% endif %}}

{{{ bash_ensure_pam_module_configuration(pam_lastlog_path, 'session', '\[default=1\]', 'pam_lastlog.so', 'showfailed', '', 'BOF') }}}
{{{ bash_remove_pam_module_option_configuration(pam_lastlog_path, 'session', '\[default=1\]', 'pam_lastlog.so', 'silent') }}}
