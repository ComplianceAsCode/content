# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_extension_whitelist") }}}

var_extension_whitelist_modified="$(echo ${var_extension_whitelist} | sed 's/\//\\\/\\/')"

{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "ExtensionInstallWhitelist", "${var_extension_whitelist_modified}", "${var_extension_whitelist}") }}}
