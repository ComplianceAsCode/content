# platform = Red Hat Enterprise Linux 7, multi_platform_fedora

replace_or_append '/etc/systemd/system.conf' '^CtrlAltDelBurstAction=' 'none' '@CCENUM@' '%s=%s'
