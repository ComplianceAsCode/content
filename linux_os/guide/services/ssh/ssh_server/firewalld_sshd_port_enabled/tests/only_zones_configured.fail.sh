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

# If the connection is already assigned to a firewalld zone, removes the assignment.
# This will not change connections which are not assigned to any firewalld zone.
for connection in $nm_connections; do
    nmcli connection modify "$connection" connection.zone ""
done
systemctl restart NetworkManager

readarray -t firewalld_all_zones < <(firewall-cmd --get-zones)

# Ensure all zones are permanently allowing SSH service.
for zone in $firewalld_all_zones; do
    firewall-cmd --permanent --zone="$zone" --add-service=ssh
done

# It is not a problem to reload the settings since all interfaces without an explicit assgined zone
# will be automatically assigned to the default zone.
firewall-cmd --reload
