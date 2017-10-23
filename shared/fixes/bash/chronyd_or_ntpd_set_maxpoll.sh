# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_time_service_set_maxpoll

if ! `/usr/sbin/pidof ntpd`; then
    config_file="/etc/chrony.conf"
else
    config_file="/etc/ntp.conf"
fi

# Add maxpoll to server entries without maxpoll
grep -P "^server((?!maxpoll).)*$" $config_file | while read -r line ; do
        sed -i "s/$line/&1 maxpoll $var_time_service_set_maxpoll/" "$config_file"
done
