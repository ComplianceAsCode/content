# platform = Mozilla Firefox
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_firefox_cfg_setting("mozilla.cfg", "browser.helperApps.alwaysAsk.force", value="true") }}}
