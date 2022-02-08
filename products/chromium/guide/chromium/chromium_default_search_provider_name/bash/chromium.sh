# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_default_search_provider_name") }}}


{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "DefaultSearchProviderName", "$(echo ${var_default_search_provider_name} | sed 's/\//\\\/\\/')", "${var_default_search_provider_name}") }}}