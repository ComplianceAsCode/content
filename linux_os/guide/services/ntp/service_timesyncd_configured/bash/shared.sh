# platform = multi_platform_sle
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_multiple_time_servers") }}}

config_file="/etc/systemd/timesyncd.d/oscap-remedy.conf"
preferred_ntp_servers='{{ var_multiple_time_servers.split(",").slice(2)[0].join("," }}'
fallback_ntp_servers='{{ var_multiple_time_servers.split(",").slice(2)[1].join("," }}'

# Comment existing NTP FallbackNTP and RootDistance settings
# TODO

# Set primary fallback NTP servers and RootDistance in drop-in configuration
echo "NTP={{ preferred_ntp_servers }}" >> "$config_file"
echo "FallbackNTP={{ fallback_ntp_servers }}" >> "$config_file"
echo "RootDistanceMax=1" >> "$config_file"
