# platform = multi_platform_ubuntu

{{%- if product == 'ubuntu2404' %}}
sshd_approved_ciphers="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr"
{{%- elif product == 'ubuntu2204' %}}
sshd_approved_ciphers="aes256-ctr,aes256-gcm@openssh.com,aes192-ctr,aes128-ctr,aes128-gcm@openssh.com"
{{%- else %}}
sshd_approved_ciphers="aes256-ctr,aes192-ctr,aes128-ctr"
{{%- endif %}}

{{{ bash_sshd_remediation(parameter="Ciphers", value="$sshd_approved_ciphers", config_is_distributed=sshd_distributed_config) }}}
