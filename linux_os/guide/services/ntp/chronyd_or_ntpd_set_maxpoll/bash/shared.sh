# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_time_service_set_maxpoll") }}}


{{% if 'sle' in product or 'ubuntu' in product %}}
pof="/bin/pidof"
{{% else %}}
pof="/usr/sbin/pidof"
{{% endif %}}

CONFIG_FILES="/etc/ntp.conf"
$pof ntpd || {
    CHRONY_NAME={{{ chrony_conf_path }}}
    CHRONY_PATH=${CHRONY_NAME%%.*}
    CONFIG_FILES=$(find ${CHRONY_PATH}.* -type f -name '*.conf')
}

# get list of ntp files

for config_file in $CONFIG_FILES; do
    # Set maxpoll values to var_time_service_set_maxpoll
    sed -i "s/^\(\(server\|pool\|peer\).*maxpoll\) [0-9][0-9]*\(.*\)$/\1 $var_time_service_set_maxpoll \3/" "$config_file"
done




for config_file in $CONFIG_FILES; do
    # Add maxpoll to server, pool or peer entries without maxpoll
    grep "^\(server\|pool\|peer\)" "$config_file" | grep -v maxpoll | while read -r line ; do
        sed -i "s/$line/& maxpoll $var_time_service_set_maxpoll/" "$config_file"
    done
done
