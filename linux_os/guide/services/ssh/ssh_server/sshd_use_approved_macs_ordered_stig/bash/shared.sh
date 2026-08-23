# platform = Oracle Linux 7,multi_platform_sle,multi_platform_slmicro

{{{ bash_sshd_remediation(
    parameter="MACs",
    value="hmac-sha2-512,hmac-sha2-256",
    config_is_distributed=sshd_distributed_config,
    rule_id=rule_id) }}}
