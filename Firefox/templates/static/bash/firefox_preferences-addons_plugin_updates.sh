# platform = Mozilla Firefox
. $SHARED_REMEDIATION_FUNCTIONS

firefox_cfg_setting "stig.cfg" "extensions.update.enabled" "false"
