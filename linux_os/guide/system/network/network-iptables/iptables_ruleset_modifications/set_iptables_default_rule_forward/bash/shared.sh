# platform = Red Hat Enterprise Linux 6,Red Hat Virtualization 4
sed -i 's/^:FORWARD ACCEPT.*/:FORWARD DROP [0:0]/g' /etc/sysconfig/iptables
