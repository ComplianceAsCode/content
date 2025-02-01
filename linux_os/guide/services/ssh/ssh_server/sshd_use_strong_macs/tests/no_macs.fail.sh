# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu,multi_platform_almalinux

sed -i 's/^\s*MACs\s/# &/i' /etc/ssh/sshd_config
