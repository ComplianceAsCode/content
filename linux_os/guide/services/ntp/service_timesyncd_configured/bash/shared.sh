# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_multiple_time_servers") }}}
IFS=',' read -r -a time_servers_array <<< "$var_multiple_time_servers"
preferred_ntp_servers_array=("${time_servers_array[@]:0:2}")
preferred_ntp_servers=$( echo "${preferred_ntp_servers_array[@]}"|sed -e 's/\s\+/,/g' )
fallback_ntp_servers_array=("${time_servers_array[@]:2}")
fallback_ntp_servers=$( echo "${fallback_ntp_servers_array[@]}"|sed -e 's/\s\+/,/g' )

IFS=" " mapfile -t current_cfg_arr < <(ls -1 /etc/systemd/timesyncd.d/* /etc/systemd/timesyncd.conf.d/* 2>/dev/null)
{{% if "ubuntu" in product %}}
config_file="/etc/systemd/timesyncd.conf.d/oscap-remedy.conf"
{{% else %}}
config_file="/etc/systemd/timesyncd.d/oscap-remedy.conf"
{{% endif %}}
current_cfg_arr+=( "/etc/systemd/timesyncd.conf" )
# Comment existing NTP FallbackNTP settings
for current_cfg in "${current_cfg_arr[@]}"
do
    sed -i 's/^NTP/#&/g' "$current_cfg"
    sed -i 's/^FallbackNTP/#&/g' "$current_cfg"
done
{{% if "ubuntu" in product %}}
if [ ! -d "/etc/systemd/timesyncd.conf.d" ]
then 
    mkdir /etc/systemd/timesyncd.conf.d
fi
{{% else %}}
# Create /etc/systemd/timesyncd.d if it doesn't exist
if [ ! -d "/etc/systemd/timesyncd.d" ]
then 
    mkdir /etc/systemd/timesyncd.d
fi
{{% endif %}}

# Set primary fallback NTP servers in drop-in configuration
echo "NTP=$preferred_ntp_servers" >> "$config_file"
echo "FallbackNTP=$fallback_ntp_servers" >> "$config_file"

