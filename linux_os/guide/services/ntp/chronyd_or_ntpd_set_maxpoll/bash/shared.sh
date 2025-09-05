# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_wrlinux,multi_platform_ol,multi_platform_sle

{{{ bash_instantiate_variables("var_time_service_set_maxpoll") }}}


config_file="/etc/ntp.conf"
/usr/sbin/pidof ntpd || config_file="/etc/chrony.conf"


# Set maxpoll values to var_time_service_set_maxpoll
sed -i "s/^\(\(server\|pool\).*maxpoll\) [0-9][0-9]*\(.*\)$/\1 $var_time_service_set_maxpoll \3/" "$config_file"

# Add maxpoll to server or pool entries without maxpoll
grep "^\(server\|pool\)" "$config_file" | grep -v maxpoll | while read -r line ; do
        sed -i "s/$line/& maxpoll $var_time_service_set_maxpoll/" "$config_file"
done
