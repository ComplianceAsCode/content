# platform = multi_platform_all

. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables("sshd_idle_timeout_value") }}}

{{{ bash_sshd_config_set("ClientAliveInterval", "$sshd_idle_timeout_value") }}}
