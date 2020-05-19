# platform = multi_platform_all

sed -e '/RekeyLimit/d' /etc/ssh/sshd_config
echo "RekeyLimit 812M 1h" >> /etc/ssh/sshd_config
