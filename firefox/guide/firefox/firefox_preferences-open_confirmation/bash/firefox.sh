# platform = Mozilla Firefox
populate var_required_file_types

{{{ bash_firefox_cfg_setting("stig.cfg", "plugin.disable_full_page_plugin_for_types", "\"${var_required_file_types}\"") }}}
