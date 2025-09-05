# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

for interface in $(ip link show | grep -E '^[0-9]' | cut -d ":" -f 2); do
    ip link set dev $interface multicast off promisc off
done
