#!/bin/bash
# variables = var_nftables_master_config_file=/etc/sysconfig/nftables.conf

# make sure that variable is set correctly on new platform adding
echo 'include /some/invalid/path' > "/etc/sysconfig/nftables.conf"
