# platform = multi_platform_all

{{{ bash_instantiate_variables("sshd_strong_macs") }}}

{{{ bash_sshd_remediation(parameter="MACs", value="$sshd_strong_macs", config_is_distributed=sshd_distributed_config, rule_id=rule_id) }}}
