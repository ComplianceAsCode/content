# platform = multi_platform_rhel

sed -i 's/^BOOTPROTO=.*/BOOTPROTO="none"/' /etc/sysconfig/network-scripts/ifcfg-*
