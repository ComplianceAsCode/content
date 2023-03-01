# platform = multi_platform_all

{{{ bash_instantiate_variables("var_multiple_time_servers") }}}

config_file="{{{ chrony_conf_path }}}"

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
