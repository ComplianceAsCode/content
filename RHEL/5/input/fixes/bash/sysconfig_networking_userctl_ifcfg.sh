find /etc/sysconfig/network-scripts/ -name ifcfg-* | while read FILE; do
	sed -i 's/^USERCTL=.*/USERCTL=no/' "${FILE}"
done
