# platform = Ubuntu 26.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_sshd_set_keepalive") }}}
{{{
    bash_sshd_remediation(
        parameter="ClientAliveCountMax",
        value="$var_sshd_set_keepalive",
        config_is_distributed=sshd_distributed_config,
        rule_id=rule_id
    )
}}}
