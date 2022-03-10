# platform = multi_platform_all

SSH_CONF="/etc/sysconfig/sshd"

sed -i "/^\s*CRYPTO_POLICY.*$/Id" $SSH_CONF
