# platform = multi_platform_all

for interface_path in /sys/class/net/*; do
	interface="${interface_path##/sys/class/net/}"
	[[ ${interface} == lo ]] && continue

	# If the interface is already in a zone, remove it
	zone=$(firewall-cmd --permanent --get-zone-of-interface="$interface")
	[[ $? -eq 0 ]] && firewall-cmd --permanent --remove-interface="$interface" --zone="$zone"
	firewall-cmd --permanent --add-interface="$interface" --zone=drop
done

sed -i -e 's/DefaultZone=public/DefaultZone=drop/g' /etc/firewalld/firewalld.conf
