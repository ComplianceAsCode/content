# platform = multi_platform_ubuntu
# packages = iptables,iptables-persistent

apt purge -y ufw nftables avahi-daemon

# listen on port 5000 and set rules for a few ports including the open ports 22 and 5000
nohup nc -6ul 5000 &>/dev/null &
ip6tables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p tcp --dport 222 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p udp --dport 5000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p udp --dport 15000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p udp --dport 50000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

