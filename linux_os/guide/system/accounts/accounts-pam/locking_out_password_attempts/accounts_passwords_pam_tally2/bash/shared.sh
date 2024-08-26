# platform = multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_password_pam_tally2") }}}
# Use a non-number regexp to force update of the value of the deny option
{{% if product in ["sle12","sle15"] %}}
{{% set cfg_file = '/etc/pam.d/login' %}}
{{% else %}}
{{% set cfg_file = '/etc/pam.d/common-auth' %}}
{{% endif %}}

{{{ bash_ensure_pam_module_option( cfg_file, 'auth', 'required', 'pam_tally2.so', 'deny', "${var_password_pam_tally2}", '') }}}
{{{ bash_ensure_pam_module_option( cfg_file, 'auth', 'required', 'pam_tally2.so', 'onerr', 'fail', '(fail)') }}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/common-account', 'account', 'required', 'pam_tally2.so', '', '', '') }}}
