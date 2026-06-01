# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
{{{ bash_instantiate_variables("sshd_strong_kex") }}}

{{%- if product == 'sle16' -%}}
    {{{
        bash_sshd_remediation_usr(
            parameter="KexAlgorithms",
            value="$sshd_strong_kex",
            copy_defaults=true,
            rule_id=rule_id
        )
    }}}
{{%- else -%}}
    {{{
        bash_sshd_remediation(
            parameter="KexAlgorithms",
            value="$sshd_strong_kex",
            config_is_distributed=sshd_distributed_config,
            rule_id=rule_id
        )
    }}}
{{%- endif -%}}
