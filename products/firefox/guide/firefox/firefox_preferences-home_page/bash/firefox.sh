# platform = Mozilla Firefox

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate var_default_home_page

{{{ bash_firefox_cfg_setting("mozilla.cfg", "browser.startup.homepage", quoted_value="${var_default_home_page}") }}}
