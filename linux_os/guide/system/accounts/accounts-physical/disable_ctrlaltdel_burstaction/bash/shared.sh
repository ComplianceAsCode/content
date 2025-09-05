# platform = multi_platform_rhel,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_sle,multi_platform_ubuntu


{{{ bash_replace_or_append('/etc/systemd/system.conf', '^CtrlAltDelBurstAction=', 'none', '%s=%s') }}}
