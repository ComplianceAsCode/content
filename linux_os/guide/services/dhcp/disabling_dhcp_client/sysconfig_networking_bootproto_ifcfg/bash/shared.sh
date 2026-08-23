# platform = multi_platform_all

for config_file in /etc/sysconfig/network-scripts/ifcfg-*; do
	if grep -q ^BOOTPROTO= $config_file; then
		sed -i 's/^BOOTPROTO=.*/BOOTPROTO=none/' $config_file
	else
		echo BOOTPROTO=none >>$config_file
	fi
done
