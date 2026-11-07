# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
# Same metadata as other sshd_lineinfile rules (e.g. sshd_set_idle_timeout).

{{% if product in ['opensuse16', 'sle16', 'slmicro6'] -%}}
{{{ bash_copy_distro_defaults("/usr/etc/ssh/sshd_config", sshd_main_config_file) }}}
{{{ lineinfile_absent(sshd_main_config_file, "^\s*Include\s*/usr/etc/ssh/sshd_config\.d/\*\.conf", sed_path_separator="#", rule_id=rule_id) }}}

{{% endif -%}}
{{{ bash_sshd_remediation(parameter="Compression", value="no", config_is_distributed=sshd_distributed_config, config_basename="00-complianceascode-hardening.conf", rule_id=rule_id, fallback_to_main_config=true) }}}
