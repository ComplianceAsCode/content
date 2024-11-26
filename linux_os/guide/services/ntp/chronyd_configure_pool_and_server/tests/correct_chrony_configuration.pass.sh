#!/bin/bash
# packages = chrony
# variables = var_multiple_time_servers=0.suse.pool.ntp.org,1.suse.pool.ntp.org,2.suse.pool.ntp.org,3.suse.pool.ntp.org
# variables = var_multiple_time_pools=0.suse.pool.ntp.org,1.suse.pool.ntp.org,2.suse.pool.ntp.org,3.suse.pool.ntp.org

var_multiple_time_servers=0.suse.pool.ntp.org,1.suse.pool.ntp.org,2.suse.pool.ntp.org,3.suse.pool.ntp.org
var_multiple_time_pools=0.suse.pool.ntp.org,1.suse.pool.ntp.org,2.suse.pool.ntp.org,3.suse.pool.ntp.org

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

# Check and configure pools in /etc/chorny.conf
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
