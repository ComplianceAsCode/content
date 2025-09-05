# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_default_search_provider_name") }}}

var_default_search_provider_name_modified="$(echo ${var_default_search_provider_name} | sed 's/\//\\\/\\/')"

{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "DefaultSearchProviderName", "${var_default_search_provider_name_modified}", "${var_default_search_provider_name}") }}}
