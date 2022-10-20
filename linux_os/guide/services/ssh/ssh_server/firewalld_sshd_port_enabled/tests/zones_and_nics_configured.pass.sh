#!/bin/bash
# packages = firewalld, NetworkManager
# variables = firewalld_sshd_zone=work

# Ensure the required services are started.
systemctl start firewalld NetworkManager

# Ensure the SSH service is enabled in run-time for the proper zone.
# This is to avoid connection issues when new interfaces are addeded to this zone.
firewall-cmd --zone=work --add-service=ssh

# Collect all NetworkManager connections names.
readarray -t nm_connections < <(nmcli -f UUID,TYPE con | grep ethernet | awk '{ print $1 }')

# If the connection is not yet assigned to a firewalld zone, assign it to the proper zone.
# This will not change connections which are already assigned to any firewalld zone.
for connection in $nm_connections; do
    current_zone=$(nmcli -f connection.zone connection show "$connection" | awk '{ print $2}')
    if [ $current_zone = "--" ]; then
        nmcli connection modify "$connection" connection.zone "work"
    fi
done
systemctl restart NetworkManager

# Active zones are zones with at least one interface assigned to it.
readarray -t firewalld_active_zones < <(firewall-cmd --get-active-zones | grep -v interfaces)

# It is possible that traffic is comming by any active interface and consequently any
# active zone. So, this make sure all active zones are permanently allowing SSH service.
for zone in $firewalld_active_zones; do
    firewall-cmd --permanent --zone="$zone" --add-service=ssh
done

firewall-cmd --reload
