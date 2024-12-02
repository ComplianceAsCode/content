# platform = multi_platform_ubuntu
# remediation = none
# packages = iptables,iptables-persistent

apt purge -y nftables ufw

ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT DROP
