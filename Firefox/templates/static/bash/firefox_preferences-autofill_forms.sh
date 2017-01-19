# platform = Mozilla Firefox
. $SHARED_REMEDIATION_FUNCTIONS

firefox_cfg_setting "stig.cfg" "browser.formfill.enable" "false"
