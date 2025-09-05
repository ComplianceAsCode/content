#!/bin/bash
# variables = var_networkmanager_dns_mode = none
# packages = NetworkManager

cat > /etc/NetworkManager/NetworkManager.conf << EOM
[main]
dns=none
EOM
