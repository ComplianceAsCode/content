# platform = multi_platform_sle

sed -i 's/^\s*KexAlgorithms\s/# &/i' /etc/ssh/sshd_config
