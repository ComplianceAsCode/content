# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
{{{ bash_instantiate_variables("sshd_strong_kex") }}}

{{{ bash_sshd_remediation(parameter="KexAlgorithms", value="$sshd_strong_kex", config_is_distributed=sshd_distributed_config, rule_id=rule_id) }}}

