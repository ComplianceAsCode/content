# platform = multi_platform_all
sed -i 's/^:FORWARD ACCEPT.*/:FORWARD DROP [0:0]/g' /etc/sysconfig/iptables
