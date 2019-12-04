# platform = Red Hat Enterprise Linux 6,multi_platform_sle
sed -i 's/^:INPUT ACCEPT.*/:INPUT DROP [0:0]/g' /etc/sysconfig/iptables
