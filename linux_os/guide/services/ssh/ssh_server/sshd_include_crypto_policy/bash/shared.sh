# platform = multi_platform_all

echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config
echo "Include /etc/crypto-policies/back-ends/opensshserver.config" >> /etc/ssh/ssh_config.d/50-redhat.conf
