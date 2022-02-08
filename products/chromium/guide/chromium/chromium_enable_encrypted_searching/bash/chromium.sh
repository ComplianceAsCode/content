# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_enable_encrypted_searching") }}}


{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "DefaultSearchProviderSearchURL", "$(echo ${var_enable_encrypted_searching} | sed 's/\//\\\/\\/')", "${var_enable_encrypted_searching}") }}}