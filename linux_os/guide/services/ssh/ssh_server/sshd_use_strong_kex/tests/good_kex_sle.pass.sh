# platform = multi_platform_sle,multi_platform_ubuntu

sed -i 's/^\s*KexAlgorithms\s.*//i' /etc/ssh/sshd_config
echo "KexAlgorithms diffie-hellman-group14-sha256" >> /etc/ssh/sshd_config
