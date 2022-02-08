# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_url_blacklist") }}}


{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "URLBlacklist", "$(echo ${var_url_blacklist}| sed 's/\//\\\/\\/')", "${var_url_blacklist}") }}}