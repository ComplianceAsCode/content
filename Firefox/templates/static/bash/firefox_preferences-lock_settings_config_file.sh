# platform = Mozilla Firefox
. $SHARED_REMEDIATION_FUNCTIONS

firefox_js_setting "stig_settings.js" "general.config.filename" "\"stig.cfg\""
