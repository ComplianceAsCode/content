# platform = SUSE Linux Enterprise 12
. /usr/share/scap-security-guide/remediation_functions
populate var_time_service_set_maxpoll

populate var_multiple_time_servers

if ! rpm -q ntp > /dev/null && ! rpm -q chrony ; then
    package_install ntp || exit 1
    systemctl enable ntpd
fi

remediated=0

config_file="/etc/ntp.conf /etc/chrony.conf"
for config_file in $config_files ; do
    [[ -f "$config_file" ]] || continue
    remediated=1

    # Set maxpoll values to var_time_service_set_maxpoll
    sed -i "s/^\(server.*maxpoll\) [0-9][0-9]*\(.*\)$/\1 $var_time_service_set_maxpoll \2/" "$config_file"


    # add time servers if none are set
    if ! grep -q '^server' "$config_file" ; then
        echo >> "$config_file"

        # spawn a sub-shell, to avoid modifying IFS globally
        (
            IFS=','
            for server in $var_multiple_time_servers ; do
                echo "server $server maxpoll $var_time_service_set_maxpoll" >> "$config_file"
            done
        )
    fi

    # Add maxpoll to server entries without maxpoll
    grep "^server" "$config_file" | grep -v maxpoll | while read -r line ; do
            sed -i "s/$line/& maxpoll $var_time_service_set_maxpoll/" "$config_file"
    done

done

[[ "$remediated" = "1" ]]
