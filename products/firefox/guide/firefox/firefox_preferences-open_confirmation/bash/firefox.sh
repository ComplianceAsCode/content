# platform = Mozilla Firefox

{{{ bash_instantiate_variables("var_required_file_types") }}}

{{{ bash_firefox_cfg_setting("mozilla.cfg", "plugin.disable_full_page_plugin_for_types", quoted_value="${var_required_file_types}", sed_separator="|") }}}
