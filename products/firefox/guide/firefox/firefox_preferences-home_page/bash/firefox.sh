# platform = Mozilla Firefox

{{{ bash_instantiate_variables("var_default_home_page") }}}

{{{ bash_firefox_cfg_setting("mozilla.cfg", "browser.startup.homepage", quoted_value="${var_default_home_page}") }}}
