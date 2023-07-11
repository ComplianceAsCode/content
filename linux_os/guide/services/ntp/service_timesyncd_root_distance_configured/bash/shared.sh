# platform = multi_platform_sle
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

config_file="/etc/systemd/timesyncd.d/oscap-remedy.conf"
current_cfg_arr=( "/etc/systemd/timesyncd.conf" )
current_cfg_arr+=("$(ls /etc/systemd/timesyncd.d/*)")
# Comment existing NTP FallbackNTP and RootDistance settings
for current_cfg in "${current_cfg_arr[@]}"
do
    sed -i 's/^RootDistanceMax/#&/g' "$current_cfg"
done
# Set primary fallback NTP servers and RootDistance in drop-in configuration
echo "RootDistanceMax=1" >> "$config_file"
