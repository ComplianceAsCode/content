# platform = Ubuntu 26.04
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{
    bash_sshd_remediation(
        parameter="PermitEmptyPasswords",
        value="no",
        config_is_distributed=sshd_distributed_config,
        rule_id=rule_id
    )
}}}
