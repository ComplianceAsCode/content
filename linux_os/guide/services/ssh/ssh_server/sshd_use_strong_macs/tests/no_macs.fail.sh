# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel

sed -i 's/^\s*MACs\s/# &/i' /etc/ssh/sshd_config
