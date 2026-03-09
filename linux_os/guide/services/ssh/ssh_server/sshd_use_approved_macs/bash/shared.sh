# platform = Oracle Linux 7,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu

{{{ bash_instantiate_variables("sshd_approved_macs") }}}

{{{ bash_sshd_remediation(
    parameter="MACs",
    value="$sshd_approved_macs",
    config_is_distributed=sshd_distributed_config,
    rule_id=rule_id) }}}
