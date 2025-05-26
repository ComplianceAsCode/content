#!/bin/bash
# variables = var_networkmanager_dns_mode = none
# packages = NetworkManager

cat > /etc/NetworkManager/NetworkManager.conf << EOM
#  this is a comment
[main]
dns=none
EOM
