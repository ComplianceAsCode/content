# platform = Mozilla Firefox
. $SHARED_REMEDIATION_FUNCTIONS

firefox_cfg_setting "stig.cfg" "security.warn_leaving_secure" "true"
