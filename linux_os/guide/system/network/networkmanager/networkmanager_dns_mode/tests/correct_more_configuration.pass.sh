#!/bin/bash
# variables = var_networkmanager_dns_mode = none
# packages = NetworkManager

cat > /etc/NetworkManager/NetworkManager.conf << EOM
[main]
config1=value1
config2=value2
dns=none
config3=value3
EOM
