# platform = multi_platform_all
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdrivermode() }}}

{{{ set_config_file(path="$RSYSLOG_D_CONF",
             parameter="\$ActionSendStreamDriverMode", value="1", create=true, separator=" ", separator_regex=" ", rule_id=rule_id)
}}}
