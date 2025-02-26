# platform = multi_platform_all
sed -i 's/^:INPUT ACCEPT.*/:INPUT DROP [0:0]/g' /etc/iptables/rules.v4
sed -i 's/^:OUTPUT ACCEPT.*/:OUTPUT DROP [0:0]/g' /etc/iptables/rules.v4
sed -i 's/^:FORWARD ACCEPT.*/:FORWARD DROP [0:0]/g' /etc/iptables/rules.v4
