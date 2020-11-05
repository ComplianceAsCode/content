# platform = Red Hat Virtualization 4
sed -i 's/^:INPUT ACCEPT.*/:INPUT DROP [0:0]/g' /etc/sysconfig/ip6tables
