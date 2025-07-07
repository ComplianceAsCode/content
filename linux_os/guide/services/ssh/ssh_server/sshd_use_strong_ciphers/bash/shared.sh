# platform = multi_platform_all

{{{ bash_sshd_remediation(parameter="Ciphers", value="aes128-ctr,aes192-ctr,aes256-ctr,chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com", config_is_distributed=sshd_distributed_config, rule_id=rule_id) }}}
