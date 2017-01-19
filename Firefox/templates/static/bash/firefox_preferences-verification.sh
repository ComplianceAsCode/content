# platform = Mozilla Firefox
. $SHARED_REMEDIATION_FUNCTIONS

firefox_cfg_setting "stig.cfg" "security.default_personal_cert" "\"Ask Every Time\""
