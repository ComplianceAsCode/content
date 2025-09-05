# platform = multi_platform_all

{{{ bash_instantiate_variables("var_logind_session_timeout") }}}

{{{ bash_ini_file_set("/etc/systemd/logind.conf", "Login", "StopIdleSessionSec", "$var_logind_session_timeout") }}}
