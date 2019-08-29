# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate inactivity_timeout_value

{{{ bash_dconf_settings("org/gnome/desktop/session", "idle-delay", "uint32 ${inactivity_timeout_value}", "local.d", "00-security-settings") }}}
{{{ bash_dconf_lock("org/gnome/desktop/session", "idle-delay", "local.d", "00-security-settings-lock") }}}
