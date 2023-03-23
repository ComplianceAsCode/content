# platform = multi_platform_all

{{{ bash_instantiate_variables("var_multiple_time_servers") }}}
{{{ bash_instantiate_variables("var_multiple_time_pools") }}}

config_file="{{{ chrony_conf_path }}}"

# Check and configigure servers in {{{ chrony_conf_path }}}
IFS="," read -a SERVERS <<< $var_multiple_time_servers
for srv in "${SERVERS[@]}"
do
   NTP_SRV=$(grep -w $srv $config_file)
   if [[ ! "$NTP_SRV" == "server "* ]]
   then
     time_server="server $srv"
     echo $time_server >> "$config_file"
   fi
done

# Check and configure pools in {{{ chrony_conf_path }}}
IFS="," read -a POOLS <<< $var_multiple_time_pools
for srv in "${POOLS[@]}"
do
   NTP_POOL=$(grep -w $srv $config_file)
   if [[ ! "$NTP_POOL" == "pool "* ]]
   then
     time_server="pool $srv"
     echo $time_server >> "$config_file"
   fi
done
