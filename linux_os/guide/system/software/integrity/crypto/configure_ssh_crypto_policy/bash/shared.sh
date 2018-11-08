# platform = multi_platform_fedora

SSH_CONF="/etc/sysconfig/sshd"

sed -i "/^\s*CRYPTO_POLICY.*$/d" $SSH_CONF
