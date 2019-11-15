# platform = multi_platform_rhel,multi_platform_fedora
# profiles = e8

sed -i 's/^\s*MACs\s/# &/i' /etc/ssh/sshd_config
