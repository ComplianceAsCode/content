# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_sshd_allow_groups") }}}

{{{ bash_sshd_remediation(parameter="AllowGroups", value="$var_sshd_allow_groups", config_is_distributed=sshd_distributed_config, rule_id=rule_id) }}}
