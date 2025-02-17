# platform = multi_platform_ubuntu,multi_platform_debian
# packages = iptables,iptables-persistent

apt purge -y nftables ufw

ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT DROP
