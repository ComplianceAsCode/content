# platform = multi_platform_all

SSH_CONF="{{{ sshd_sysconfig_file }}}"

sed -i "/^\s*CRYPTO_POLICY.*$/Id" $SSH_CONF
