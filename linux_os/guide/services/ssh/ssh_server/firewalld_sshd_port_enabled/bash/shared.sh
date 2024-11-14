# platform = multi_platform_all
# reboot = false
# complexity = low
# strategy = configure
# disruption = low

{{{ bash_package_install("firewalld") }}}
{{{ bash_package_install("NetworkManager") }}}
{{{ bash_instantiate_variables("firewalld_sshd_zone") }}}

if {{{ bash_bootc_build() }}}; then
    # By default, NetworkManager interfaces are created only once
    # container image is booted so we do not have information about
    # what interfaces will be created during container build time.
    # Therefore, we will rely on NetworkManager to automatically assign
    # interfaces to the default firewalld zone. For more details see:
    # https://firewalld.org/documentation/man-pages/firewalld.zone.html
    # https://firewalld.org/documentation/zone/connections-interfaces-and-sources.html
    # That also means this remediation only works if zone defined in
    # the firewalld_sshd_zone variable equals to the default zone of firewalld.
    default_zone=$(firewall-offline-cmd --get-default-zone)
    if [ "$firewalld_sshd_zone" != "$default_zone" ]; then
        echo "Firewalld default zone ($default_zone) and pre-set zone for sshd ($firewalld_sshd_zone) differ. Remediation aborted!" >&2
        exit 1
    fi

    # Make sure default zone is set in all existing NetworkManager keyfiles.
    while IFS= read -r -d '' file; do
        sed "s|^\s*zone=.*$|zone=$firewalld_sshd_zone|g" "$file"
    done < <(find /etc/NetworkManager/system-connections -maxdepth 1 -name "*.nmconnection" -print0)

    firewall-offline-cmd --zone="$firewalld_sshd_zone" --add-service=ssh
else
    if {{{ in_chrooted_environment }}}; then
        # TODO: NM (nmcli) now has --offline mode support, and it could operate without NM service.
        # See: https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/merge_requests/1183
        # The feature is not quite straighforward (and probably incomplete), though.
        echo "Not applicable in offline mode. Remediation aborted!"
    else
        if systemctl is-active NetworkManager && systemctl is-active firewalld; then
            # First make sure the SSH service is enabled in run-time for the proper zone.
            # This is to avoid connection issues when new interfaces are addeded to this zone.
            firewall-cmd --zone="$firewalld_sshd_zone" --add-service=ssh

            # This will collect all NetworkManager connections names
            readarray -t nm_connections < <(nmcli -g UUID,TYPE con | grep -v loopback | awk -F ':' '{ print $1 }')
            # If the connection is not yet assigned to a firewalld zone, assign it to the proper zone.
            # This will not change connections which are already assigned to any firewalld zone.
            for connection in "${nm_connections[@]}"; do
                current_zone=$(nmcli -f connection.zone connection show "$connection" | awk '{ print $2}')
                if [ $current_zone = "--" ]; then
                    nmcli connection modify "$connection" connection.zone $firewalld_sshd_zone
                fi
            done
            systemctl restart NetworkManager

            # Active zones are zones with at least one interface assigned to it.
            # It is possible that traffic is coming by any active interface and consequently any
            # active zone. So, this make sure all active zones are permanently allowing SSH service.
            readarray -t firewalld_active_zones < <(firewall-cmd --get-active-zones | grep -v "^ " | cut -d " " -f 1)
            for zone in "${firewalld_active_zones[@]}"; do
                firewall-cmd --permanent --zone="$zone" --add-service=ssh
            done
            firewall-cmd --reload
        else
            echo "The firewalld or NetworkManager service is not active. Remediation aborted!"
        fi
    fi
fi
