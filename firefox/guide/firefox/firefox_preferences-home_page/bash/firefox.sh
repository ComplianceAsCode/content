# platform = Mozilla Firefox
populate var_default_home_page

{{{ bash_firefox_cfg_setting("stig.cfg", "browser.startup.homepage", "\"${var_default_home_page}\"") }}}
