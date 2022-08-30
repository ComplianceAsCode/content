# platform = multi_platform_ol,multi_platform_rhel

{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^MACs', "hmac-sha2-512,hmac-sha2-256,hmac-sha1,hmac-sha1-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com", '%s %s') }}}
