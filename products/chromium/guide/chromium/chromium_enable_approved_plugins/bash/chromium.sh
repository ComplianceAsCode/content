# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_enable_approved_plugins") }}}

# set var to empty string if None
if [ "$var_enable_approved_plugins" = "None" ]; then
    var_enable_approved_plugins=""
fi

var_enable_approved_plugins_modified="$(echo ${var_enable_approved_plugins} | sed 's/\//\\\/\\/')"

{{{ bash_chromium_pol_setting("chrome_stig_policy.json", "/etc/chromium/policies/managed/", "EnabledPlugins", "\[${var_enable_approved_plugins_modified}\]", "\[${var_enable_approved_plugins}\]") }}}
