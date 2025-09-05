# platform = multi_platform_all

{{{ bash_ensure_ini_config("/etc/dnf/automatic.conf", "commands", "upgrade_type", "security") }}}
