# platform = Ubuntu 26.04
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

weak_kex='-diffie-hellman-group1-sha1,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1'
{{{
    bash_sshd_remediation(
        parameter="KexAlgorithms",
        value="$weak_kex",
        config_is_distributed=sshd_distributed_config,
        rule_id=rule_id
    )
}}}
