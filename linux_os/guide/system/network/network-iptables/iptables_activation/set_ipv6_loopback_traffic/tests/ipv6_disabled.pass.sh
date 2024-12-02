# platform = multi_platform_ubuntu
# packages = iptables,iptables-persistent

apt purge -y nftables ufw

ip6tables -F
sysctl net.ipv6.conf.all.disable_ipv6=1
