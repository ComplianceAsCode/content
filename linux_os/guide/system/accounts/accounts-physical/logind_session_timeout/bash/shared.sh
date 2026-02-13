# platform = multi_platform_all

{{{ bash_instantiate_variables("var_logind_session_timeout") }}}

{{% if product in ["ol9", "ol10", "rhel9", "rhel10", "sle15", "sle16"] %}}
# create drop-in in the /etc/systemd/logind.conf.d/ directory
{{% set logind_conf_file = "/etc/systemd/logind.conf.d/oscap-idle-sessions.conf" %}}
{{% else %}}
{{% set logind_conf_file = "/etc/systemd/logind.conf" %}}
{{% endif %}}


{{{ bash_ini_file_set(logind_conf_file, "Login", "StopIdleSessionSec", "$var_logind_session_timeout", rule_id=rule_id) }}}
