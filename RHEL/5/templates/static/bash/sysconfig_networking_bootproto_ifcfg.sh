# platform = Red Hat Enterprise Linux 5
sed -i 's/^BOOTPROTO=.*/BOOTPROTO="static"/' /etc/sysconfig/network-scripts/ifcfg-*