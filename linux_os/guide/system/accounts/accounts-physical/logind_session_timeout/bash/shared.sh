# platform = multi_platform_all

{{{ bash_instantiate_variables("var_logind_session_timeout") }}}

# Remove StopIdleSessionSec from main config
{{{ lineinfile_absent("/etc/systemd/logind.conf", "^\s*StopIdleSessionSec\s*=", insensitive=true, rule_id=rule_id) }}}

{{% if product in ["ol9", "ol10", "rhel9", "rhel10", "sle15", "sle16"] %}}
# create drop-in in the /etc/systemd/logind.conf.d/ directory
{{% set logind_conf_file = "/etc/systemd/logind.conf.d/oscap-idle-sessions.conf" %}}
mkdir -p "/etc/systemd/logind.conf.d/"
# remove StopIdleSessionSec from drop-in files
{{{ lineinfile_absent_in_directory("/etc/systemd/logind.conf.d", "^\s*StopIdleSessionSec\s*=", insensitive=true, filename_glob="*.conf") | indent(4) }}}
{{% else %}}
{{% set logind_conf_file = "/etc/systemd/logind.conf" %}}
{{% endif %}}


{{{ bash_ini_file_set(logind_conf_file, "Login", "StopIdleSessionSec", "$var_logind_session_timeout", rule_id=rule_id) }}}
