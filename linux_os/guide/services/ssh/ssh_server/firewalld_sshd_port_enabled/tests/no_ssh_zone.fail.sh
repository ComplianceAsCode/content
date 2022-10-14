#!/bin/bash
# packages = firewalld

all_zones=$(firewall-cmd --get-zones)
for zone in $all_zones;do
    firewall-cmd --permanent --zone=$zone --remove-service=ssh
done

# Do not reload, otherwise SSG Test suite will be locked out
# firewall-cmd --reload
