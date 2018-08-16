# platform = Mozilla Firefox
. /usr/share/scap-security-guide/remediation_functions

firefox_cfg_setting "stig.cfg" "signon.rememberSignons" "false"
