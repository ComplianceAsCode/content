# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,multi_platform_fedora

{{{ bash_instantiate_variables("sshd_approved_ciphers") }}}
{{%- set openssh_client_policy_file = openssh_client_crypto_policy_config_file -%}}

{{{ set_config_file(
        path=openssh_client_policy_file,
        parameter="Ciphers",
        value="${sshd_approved_ciphers}",
        create=true,
        insensitive=false,
        prefix_regex="^.*", rule_id=rule_id)
}}}
