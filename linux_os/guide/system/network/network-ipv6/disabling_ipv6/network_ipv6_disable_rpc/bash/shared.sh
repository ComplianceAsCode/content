# platform = Red Hat Virtualization 4,multi_platform_rhel

# Drop 'tcp6' and 'udp6' entries from /etc/netconfig to prevent RPC
# services for NFSv4 from attempting to start IPv6 network listeners
declare -a IPV6_RPC_ENTRIES=("tcp6" "udp6")

for rpc_entry in "${IPV6_RPC_ENTRIES[@]}"
do
	sed -i "/^${rpc_entry}[[:space:]]\\+tpi\\_.*inet6.*/d" /etc/netconfig
done
