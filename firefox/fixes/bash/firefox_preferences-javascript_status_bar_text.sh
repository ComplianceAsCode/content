# platform = Mozilla Firefox
. /usr/share/scap-security-guide/remediation_functions

firefox_cfg_setting "stig.cfg" "dom.disable_window_open_feature.status" "true"
