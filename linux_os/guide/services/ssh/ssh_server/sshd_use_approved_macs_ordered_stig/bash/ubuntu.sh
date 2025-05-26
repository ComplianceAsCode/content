# platform = multi_platform_ubuntu

{{%- if product == 'ubuntu2404' %}}
sshd_approved_macs="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"
{{%- elif product == 'ubuntu2204' %}}
sshd_approved_macs="hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com"
{{%- else %}}
sshd_approved_macs="hmac-sha2-512,hmac-sha2-256"
{{%- endif %}}

{{{ bash_sshd_remediation(parameter="MACs", value="$sshd_approved_macs", config_is_distributed=sshd_distributed_config) }}}
