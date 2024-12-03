# platform = multi_platform_ubuntu
# packages = iptables,iptables-persistent

apt purge -y ufw nftables avahi-daemon

# listen on port 5000 and set rules for a few ports, not including the open ports 22 and 5000
nohup nc -6l 5000 &>/dev/null &
ip6tables -A INPUT -p tcp --match multiport --dport 222,15000,50000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

