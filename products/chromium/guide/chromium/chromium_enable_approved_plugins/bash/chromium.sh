# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_enable_approved_plugins") }}}


{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "EnabledPlugins", "$(echo ${var_enable_approved_plugins} | sed 's/\//\\\/\\/')", "${var_enable_approved_plugins}") }}}