# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_time_service_set_maxpoll

if ! [ `/usr/sbin/pidof ntpd` ] ; then
    config_file="/etc/chrony.conf"
else
    config_file="/etc/ntp.conf"
fi

# Set maxpoll values to var_time_service_set_maxpoll
sed -i "s/^\(server.*maxpoll\) [0-9][0-9]*\(.*\)$/\1 $var_time_service_set_maxpoll \2/" "$config_file"

# Add maxpoll to server entries without maxpoll
grep -P "^server((?!maxpoll).)*$" $config_file | while read -r line ; do
        sed -i "s/$line/&1 maxpoll $var_time_service_set_maxpoll/" "$config_file"
done
