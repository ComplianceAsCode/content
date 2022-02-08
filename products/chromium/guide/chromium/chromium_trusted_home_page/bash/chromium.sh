# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_trusted_home_page") }}}


{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "HomepageLocation", "$(echo ${var_trusted_home_page} | sed 's/\//\\\/\\/')", "${var_trusted_home_page}") }}}