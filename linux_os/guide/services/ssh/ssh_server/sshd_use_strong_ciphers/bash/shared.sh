# platform = multi_platform_all

{{{ bash_sshd_config_set(parameter="Ciphers", value="aes128-ctr,aes192-ctr,aes256-ctr,chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com") }}}
