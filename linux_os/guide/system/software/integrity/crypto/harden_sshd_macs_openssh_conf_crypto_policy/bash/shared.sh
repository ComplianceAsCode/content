# platform = Red Hat Enterprise Linux 8,multi_platform_ol,multi_platform_fedora

{{{ bash_instantiate_variables("sshd_approved_macs") }}}
{{%- set openssh_client_policy_file = openssh_client_crypto_policy_config_file -%}}

{{{ set_config_file(
        path=openssh_client_policy_file,
        parameter="MACs",
        value="${sshd_approved_macs}",
        create=true,
        insensitive=false,
        prefix_regex="^.*", rule_id=rule_id)
}}}
