# platform = Oracle Linux 7,multi_platform_sle,multi_platform_slmicro

{{% if product in ['sle16', 'slmicro6'] %}}
    {{{ bash_copy_distro_defaults("/usr/etc/ssh/sshd_config", sshd_main_config_file) }}}
    {{{ lineinfile_absent(sshd_main_config_file, "^\s*Include\s*/usr/etc/ssh/sshd_config\.d/\*\.conf", sed_path_separator="#", rule_id=rule_id) }}}
{{% endif %}}

{{{ bash_sshd_remediation(
    parameter="Ciphers",
    value="aes256-ctr,aes192-ctr,aes128-ctr",
    config_is_distributed=sshd_distributed_config,
    rule_id=rule_id) }}}
