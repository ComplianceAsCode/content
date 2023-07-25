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

config_file="/etc/systemd/timesyncd.d/oscap-remedy.conf"
current_cfg_arr=( "/etc/systemd/timesyncd.conf" )
current_cfg_arr+=("$(ls /etc/systemd/timesyncd.d/*)")
# Comment existing NTP FallbackNTP and RootDistance settings
for current_cfg in "${current_cfg_arr[@]}"
do
    sed -i 's/^NTP/#&/g' "$current_cfg"
    sed -i 's/^FallbackNTP/#&/g' "$current_cfg"
done
# Set primary fallback NTP servers and RootDistance in drop-in configuration
echo "NTP=$preferred_ntp_servers" >> "$config_file"
echo "FallbackNTP=$fallback_ntp_servers" >> "$config_file"

