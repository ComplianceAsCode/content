# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_url_blacklist") }}}

var_url_blacklist_modified="$(echo ${var_url_blacklist}| sed 's/\//\\\/\\/')"

{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "URLBlacklist", "\[${var_url_blacklist_modified}\]", "\[${var_url_blacklist}\]") }}}
