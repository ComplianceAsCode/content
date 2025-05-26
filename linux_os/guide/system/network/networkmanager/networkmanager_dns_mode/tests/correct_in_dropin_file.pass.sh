#!/bin/bash
# variables = var_networkmanager_dns_mode = none
# packages = NetworkManager

sed -i 's/^.*dns=.*$/d' /etc/NetworkManager/NetworkManager.conf

cat > /etc/NetworkManager/conf.d/test.conf << EOM
[main]
dns=none
EOM
