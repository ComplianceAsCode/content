# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
{{{ bash_instantiate_variables("sshd_strong_kex") }}}

{{% if product in ['sle16', 'slmicro6'] %}}
    {{{ bash_copy_distro_defaults("/usr/etc/ssh/sshd_config", sshd_main_config_file) }}}
    {{{ lineinfile_absent(sshd_main_config_file, "^\s*Include\s*/usr/etc/ssh/sshd_config\.d/\*\.conf", sed_path_separator="#", rule_id=rule_id) }}}
{{% endif %}}
{{{
    bash_sshd_remediation(
        parameter="KexAlgorithms",
        value="$sshd_strong_kex",
        config_is_distributed=sshd_distributed_config,
        rule_id=rule_id
    )
}}}
