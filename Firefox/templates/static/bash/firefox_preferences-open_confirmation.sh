# platform = Mozilla Firefox
. $SHARED_REMEDIATION_FUNCTIONS
populate var_required_file_types

firefox_cfg_setting "stig.cfg" "plugin.disable_full_page_plugin_for_types" "\"${var_required_file_types}\""
