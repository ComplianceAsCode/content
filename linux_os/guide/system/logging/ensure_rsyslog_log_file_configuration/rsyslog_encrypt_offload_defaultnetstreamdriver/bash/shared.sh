# platform = multi_platform_all
{{{ setup_rsyslog_encrypt_offload_defaultnetstreamdriver() }}}

{{{ set_config_file(path="$RSYSLOG_D_CONF",
                    parameter="\$DefaultNetstreamDriver", value="gtls", create=true, separator=" ", separator_regex=" ", rule_id=rule_id)
}}}
