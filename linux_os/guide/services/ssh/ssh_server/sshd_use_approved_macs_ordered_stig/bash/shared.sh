# platform = Oracle Linux 7,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu

{{%- if product == 'ubuntu2404' %}}
sshd_approved_macs="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"
{{%- elif product == 'ubuntu2204' %}}
sshd_approved_macs="hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com"
{{%- else %}}
sshd_approved_macs="hmac-sha2-512,hmac-sha2-256"
{{%- endif %}}

{{% if product in ['sle16', 'slmicro6'] %}}
    {{{ bash_copy_distro_defaults("/usr/etc/ssh/sshd_config", sshd_main_config_file) }}}
    {{{ lineinfile_absent(sshd_main_config_file, "^\s*Include\s*/usr/etc/ssh/sshd_config\.d/\*\.conf", sed_path_separator="#", rule_id=rule_id) }}}
{{% endif %}}

{{{ bash_sshd_remediation(
    parameter="MACs",
    value="$sshd_approved_macs",
    config_is_distributed=sshd_distributed_config,
    rule_id=rule_id)
}}}
