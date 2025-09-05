# platform = multi_platform_all

{{{ bash_sshd_config_set(parameter="MACs", value="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160") }}}

