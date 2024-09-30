# platform = multi_platform_all

{{% if 'sle' in product or 'ubuntu' in product %}}
pof="/bin/pidof"
{{% else %}}
pof="/usr/sbin/pidof"
{{% endif %}}

CONFIG_FILES="/etc/ntp.conf"
$pof ntpd || {
    CHRONY_D_PATH={{{ chrony_d_path }}}
    mapfile -t CONFIG_FILES < <(find ${CHRONY_D_PATH}.* -type f -name '*.conf')
    CONFIG_FILES+=({{{ chrony_conf_path }}})
}

# get list of ntp files

for config_file in "${CONFIG_FILES[@]}" ; do
    # Add maxpoll to server, pool or peer entries without maxpoll
    grep "^\(server\|pool\|peer\)" "$config_file" | grep -v maxpoll | while read -r line ; do
        sed -i "s/$line/& nts/" "$config_file"
    done
done
