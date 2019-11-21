# platform = multi_platform_all

# Prevent the IPv6 kernel module (ipv6) from loading the IPv6 networking stack
echo "options ipv6 disable=1" > /etc/modprobe.d/ipv6.conf

# Since according to: https://access.redhat.com/solutions/72733
# "ipv6 disable=1" options doesn't always disable the IPv6 networking stack from
# loading, instruct also sysctl configuration to disable IPv6 according to:
# https://access.redhat.com/solutions/8709#rhel6disable

declare -a IPV6_SETTINGS=("net.ipv6.conf.all.disable_ipv6" "net.ipv6.conf.default.disable_ipv6")

for setting in "${IPV6_SETTINGS[@]}"
do
	# Set runtime =1 for setting
	/sbin/sysctl -q -n -w "$setting=1"

	# If setting is present in /etc/sysctl.conf, change value to "1"
	# else, add "$setting = 1" to /etc/sysctl.conf
	if grep -q ^"$setting" /etc/sysctl.conf ; then
		sed -i "s/^$setting.*/$setting = 1/g" /etc/sysctl.conf
	else
		echo "" >> /etc/sysctl.conf
		echo "# Set $setting = 1 per security requirements" >> /etc/sysctl.conf
		echo "$setting = 1" >> /etc/sysctl.conf
	fi
done
