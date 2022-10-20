# platform = multi_platform_all
# reboot = false
# complexity = low
# strategy = configure
# disruption = low

{{{ bash_package_install("firewalld") }}}
{{{ bash_package_install("NetworkManager") }}}
{{{ bash_instantiate_variables("firewalld_sshd_zone") }}}

if firewall-cmd --state -q; then
    # First make sure the SSH service is enabled in run-time for the proper zone.
    # This is to avoid connection issues when new interfaces are addeded to this zone.
    firewall-cmd --zone="$firewalld_sshd_zone" --add-service=ssh

    if systemctl is-active NetworkManager; then
        # This will collect all NetworkManager connections names
        readarray -t nm_connections < <(nmcli --fields CONNECTION device status | grep -v "\-\-" | tail -n+2)

        # If the connection is not yet assigned to a firewalld zone, assign it to the proper zone.
        # This will not change connections which are already assigned to any firewalld zone.
        for connection in "${nm_connections[@]}"; do
            current_zone=$(nmcli -f connection.zone connection show "$connection" | awk '{ print $2}')
            if [ $current_zone = "--" ]; then
                nmcli connection modify "$connection" connection.zone $firewalld_sshd_zone
            fi
        done
        systemctl restart NetworkManager
    else
        echo "
        NetworkManager service is not active. Remediation aborted!
        This remediation could not be applied because it depends on NetworkManager service running.
        The service is not started by this remediation in order to prevent connection issues."
        exit 1
    fi

    # Active zones are zones with at least one interface assigned to it.
    # It is possible that traffic is comming by any active interface and consequently any
    # active zone. So, this make sure all active zones are permanently allowing SSH service.
    readarray -t firewalld_active_zones < <(firewall-cmd --get-active-zones | grep -v interfaces)
    for zone in "${firewalld_active_zones[@]}"; do
        firewall-cmd --permanent --zone="$zone" --add-service=ssh
    done
    firewall-cmd --reload
else
    echo "
    firewalld service is not active. Remediation aborted!
    This remediation could not be applied because it depends on firewalld service running.
    The service is not started by this remediation in order to prevent connection issues."
    exit 1
fi
