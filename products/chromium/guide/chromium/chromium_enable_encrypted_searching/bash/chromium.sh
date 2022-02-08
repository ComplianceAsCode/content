# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_enable_encrypted_searching") }}}

var_enable_encrypted_searching_modified="$(echo ${var_enable_encrypted_searching} | sed 's/\//\\\/\\/')"

{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "DefaultSearchProviderSearchURL", "${var_enable_encrypted_searching_modified}", "${var_enable_encrypted_searching}") }}}
