# platform = multi_platform_rhel

# Drop 'tcp6' and 'udp6' entries from /etc/netconfig to prevent RPC
# services for NFSv4 from attempting to start IPv6 network listeners

for rpc_entry in "tcp6" "udp6"
do
	sed -i "/^$rpc_entry[[:space:]]\+tpi_.*inet6.*/d" /etc/netconfig
done
