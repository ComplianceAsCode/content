# platform = Mozilla Firefox
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_firefox_cfg_setting("stig.cfg", "dom.disable_window_open_feature.status", "true") }}}
