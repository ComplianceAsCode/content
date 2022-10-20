#!/bin/bash
# packages = firewalld, NetworkManager
# variables = firewalld_sshd_zone=work

# Ensure the required services are started.
systemctl start firewalld NetworkManager

# Create a custom zone
custom_zone_name="custom"
firewall-cmd --new-zone=$custom_zone_name --permanent
firewall-cmd --reload

# Ensure the SSH service is enabled in run-time for the proper zone.
# This is to avoid connection issues when new interfaces are addeded to this zone.
firewall-cmd --zone=$custom_zone_name --add-service=ssh

# Collect all NetworkManager connections names.
readarray -t nm_connections < <(nmcli -f UUID,TYPE con | grep ethernet | awk '{ print $1 }')

# If the connection is not yet assigned to a firewalld zone, assign it to the proper zone.
# This will not change connections which are already assigned to any firewalld zone.
for connection in $nm_connections; do
    nmcli connection modify "$connection" connection.zone "$custom_zone_name"
done
systemctl restart NetworkManager

# Active zones are zones with at least one interface assigned to it.
readarray -t firewalld_active_zones < <(firewall-cmd --get-active-zones | grep -v interfaces)

# It is possible that traffic is comming by any active interface and consequently any
# active zone. So, this make sure all active zones are permanently allowing SSH service.
for zone in $firewalld_active_zones "$custom_zone_name"; do
    firewall-cmd --permanent --zone="$zone" --remove-service=ssh
done

# Do not reload, otherwise SSG Test suite will be locked out.
#firewall-cmd --reload
