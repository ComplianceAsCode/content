# platform = Mozilla Firefox
. /usr/share/scap-security-guide/remediation_functions
populate var_default_home_page

firefox_cfg_setting "stig.cfg" "browser.startup.homepage" "\"${var_default_home_page}\""
