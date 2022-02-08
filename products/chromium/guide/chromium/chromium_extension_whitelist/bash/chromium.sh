# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_extension_whitelist") }}}


{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "ExtensionInstallWhitelist", "$(echo ${var_extension_whitelist} | sed 's/\//\\\/\\/')", "${var_extension_whitelist}") }}}