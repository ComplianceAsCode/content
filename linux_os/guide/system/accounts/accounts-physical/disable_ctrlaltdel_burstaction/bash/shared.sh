# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol


{{{ bash_replace_or_append('/etc/systemd/system.conf', '^CtrlAltDelBurstAction=', 'none', '@CCENUM@', '%s=%s') }}}
