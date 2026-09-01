# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
# Same metadata as other sshd_lineinfile rules (e.g. sshd_set_idle_timeout).

{{{ bash_sshd_remediation(parameter="Compression", value="no", config_is_distributed=sshd_distributed_config, config_basename="00-complianceascode-hardening.conf", rule_id=rule_id) }}}
