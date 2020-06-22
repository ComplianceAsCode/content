# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_wrlinux,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate var_time_service_set_maxpoll


config_file="/etc/ntp.conf"
/usr/sbin/pidof ntpd || config_file="/etc/chrony.conf"


# Set maxpoll values to var_time_service_set_maxpoll
sed -i "s/^\(server.*maxpoll\) [0-9][0-9]*\(.*\)$/\1 $var_time_service_set_maxpoll \2/" "$config_file"

# Add maxpoll to server entries without maxpoll
sed -i "/maxpoll/! s/^\(server [0-9.]\+\)/\1 maxpoll $var_time_service_set_maxpoll/g" "$config_file"
