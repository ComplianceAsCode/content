# platform = multi_platform_rhel,multi_platform_fedora
# profiles = e8

sed -i 's/^\s*Ciphers\s.*//i' /etc/ssh/sshd_config
echo "Ciphers aes256-ctr" >> /etc/ssh/sshd_config

