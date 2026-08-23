# platform = multi_platform_all

{{{ bash_instantiate_variables("sshd_approved_ciphers") }}}

{{{ bash_sshd_remediation(
    parameter="Ciphers",
    value="$sshd_approved_ciphers",
    config_is_distributed=sshd_distributed_config,
    rule_id=rule_id) }}}
