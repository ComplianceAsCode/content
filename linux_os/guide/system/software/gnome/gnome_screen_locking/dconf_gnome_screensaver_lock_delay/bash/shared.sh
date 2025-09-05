# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_screensaver_lock_delay") }}}

{{{ bash_dconf_settings("org/gnome/desktop/screensaver", "lock-delay", "uint32 ${var_screensaver_lock_delay}", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/desktop/screensaver", "lock-delay", "local.d", "00-security-settings-lock") }}}
