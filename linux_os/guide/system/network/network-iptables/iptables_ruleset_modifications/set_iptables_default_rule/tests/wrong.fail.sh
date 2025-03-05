# platform = multi_platform_ubuntu
# remediation = none
# packages = iptables,iptables-persistent

apt purge -y nftables ufw

iptables -A INPUT -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT

iptables -P INPUT ACCEPT
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
