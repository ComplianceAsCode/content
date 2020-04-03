# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8,Red Hat Virtualization 4

SSH_CONF="/etc/sysconfig/sshd"

sed -i "/^\s*CRYPTO_POLICY.*$/d" $SSH_CONF
