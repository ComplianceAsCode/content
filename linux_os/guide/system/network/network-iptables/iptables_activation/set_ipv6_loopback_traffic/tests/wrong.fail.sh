# platform = multi_platform_ubuntu
# remediation = none
# packages = iptables,iptables-persistent

apt purge -y nftables ufw

ip6tables -F
