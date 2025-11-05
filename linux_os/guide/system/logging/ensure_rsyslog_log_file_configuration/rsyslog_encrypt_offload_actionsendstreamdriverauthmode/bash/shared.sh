# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
# reboot = false
# strategy = configure
# complexity = low
# disruption = low
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdriverauthmode() }}}

{{{ set_config_file(path="$RSYSLOG_D_CONF",
             parameter="\$ActionSendStreamDriverAuthMode", value="x509/name", create=true, separator=" ", separator_regex=" ", rule_id=rule_id)
}}}
