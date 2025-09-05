# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_auth_schema") }}}

{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "AuthSchemes", '${var_auth_schema}') }}}
