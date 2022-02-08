# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_trusted_home_page") }}}

var_trusted_home_page_modified="$(echo ${var_trusted_home_page} | sed 's/\//\\\/\\/')"

{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "HomepageLocation", "${var_trusted_home_page_modified}", "${var_trusted_home_page}") }}}
