# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

for interface in $(ip -o link show | cut -d ":" -f 2); do
    ip link set dev $interface multicast off promisc off
done
