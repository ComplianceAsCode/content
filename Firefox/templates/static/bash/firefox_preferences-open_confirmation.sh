# platform = Mozilla Firefox
. /usr/share/scap-security-guide/remediation_functions
populate var_required_file_types

firefox_cfg_setting "stig.cfg" "plugin.disable_full_page_plugin_for_types" "\"${var_required_file_types}\""
