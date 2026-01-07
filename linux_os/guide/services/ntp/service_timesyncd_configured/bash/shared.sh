# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_multiple_time_servers") }}}
IFS=',' read -r -a time_servers_array <<< "$var_multiple_time_servers"
preferred_ntp_servers_array=("${time_servers_array[@]:0:2}")
preferred_ntp_servers=$( echo "${preferred_ntp_servers_array[@]}" )
fallback_ntp_servers_array=("${time_servers_array[@]:2}")
fallback_ntp_servers=$( echo "${fallback_ntp_servers_array[@]}" )

IFS=" " mapfile -t current_cfg_arr < <(ls -1 /etc/systemd/timesyncd.d/* /etc/systemd/timesyncd.conf.d/* 2>/dev/null)

current_cfg_arr+=( "/etc/systemd/timesyncd.conf" )
# Comment existing NTP FallbackNTP settings
for current_cfg in "${current_cfg_arr[@]}"
do
    sed -i 's/^NTP/#&/g' "$current_cfg"
    sed -i 's/^FallbackNTP/#&/g' "$current_cfg"
done

# Set primary fallback NTP servers in drop-in configuration
{{% if "ubuntu" in product %}}
# Create /etc/systemd/timesyncd.conf.d if it doesn't exist
if [ ! -d "/etc/systemd/timesyncd.conf.d" ]
then 
    mkdir /etc/systemd/timesyncd.conf.d
fi

{{{ bash_ini_file_set("/etc/systemd/timesyncd.conf.d/oscap-remedy.conf", "Time", "NTP", "$preferred_ntp_servers", rule_id=rule_id) }}}
{{{ bash_ini_file_set("/etc/systemd/timesyncd.conf.d/oscap-remedy.conf", "Time", "FallbackNTP", "$fallback_ntp_servers", rule_id=rule_id) }}}
{{% else %}}
# Create /etc/systemd/timesyncd.d if it doesn't exist
if [ ! -d "/etc/systemd/timesyncd.d" ]
then 
    mkdir /etc/systemd/timesyncd.d
fi

{{{ bash_ini_file_set("/etc/systemd/timesyncd.d/oscap-remedy.conf", "Time", "NTP", "$preferred_ntp_servers", rule_id=rule_id) }}}
{{{ bash_ini_file_set("/etc/systemd/timesyncd.d/oscap-remedy.conf", "Time", "FallbackNTP", "$fallback_ntp_servers", rule_id=rule_id) }}}
{{% endif %}}


