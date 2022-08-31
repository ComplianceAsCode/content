# platform = multi_platform_all
# variables = var_rekey_limit_size=512M

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing
sed -i '/^\s*RekeyLimit\b/Id' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
echo "RekeyLimit 512M 2h" >> /etc/ssh/sshd_config
