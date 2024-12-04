# platform = multi_platform_ubuntu
# packages = iptables,iptables-persistent

apt purge -y nftables ufw

ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
ip6tables -A INPUT -s ::1 -j DROP
