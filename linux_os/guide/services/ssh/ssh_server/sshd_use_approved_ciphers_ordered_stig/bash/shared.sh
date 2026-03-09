# platform = Oracle Linux 7,multi_platform_sle,multi_platform_slmicro

{{{ bash_sshd_remediation(
    parameter="Ciphers",
    value="aes256-ctr,aes192-ctr,aes128-ctr",
    config_is_distributed=sshd_distributed_config,
    rule_id=rule_id) }}}
