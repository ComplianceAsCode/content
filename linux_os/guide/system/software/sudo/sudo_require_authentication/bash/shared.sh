# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{% if product in [ 'sle16', 'slmicro6' ] %}}
{{{ bash_copy_distro_defaults("/usr/etc/sudoers", "/etc/sudoers") }}}
{{{ lineinfile_absent("/etc/sudoers", "^\s*@includedir\s*/usr/etc/sudoers\.d", sed_path_separator="#", rule_id=rule_id) }}}
{{% endif %}}
{{{ bash_sudo_remove_config("NOPASSWD", "NOPASSWD[\s]*\:") }}}

{{{ bash_sudo_remove_config("!authenticate", "\!authenticate") }}}
