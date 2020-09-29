#!/bin/bash
# packages = firewalld
#
# remediation = none
# profiles = xccdf_org.ssgproject.content_profile_ospp

# ensure firewalld installed

# Make sure there is only one zone with ssh service enabled
all_zones=$(firewall-cmd --get-zones)
for zone in $all_zones;do
    firewall-cmd --permanent --zone=$zone --remove-service=ssh
done
firewall-cmd --permanent --zone=work --add-service=ssh

all_interfaces=$(ip link show up | cut -d ' ' -f2 | cut -d ':' -s -f1)

# Make sure NICs are bounded to no zone
for zone in $all_zones; do
    for interface in $all_interfaces; do
        firewall-cmd --permanent --zone=$zone --remove-interface=$interface
    done
done

eth_interfaces=$(echo "$all_interfaces" | grep -E '^(en|eth)')
# Add interface to wrong zone
firewall-cmd --permanent --zone=trusted --add-interface=${eth_interfaces[0]}

# Do not reload, otherwise SSG Test suite will be locked out
# firewall-cmd --reload
