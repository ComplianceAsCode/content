#!/bin/bash
# variables = var_networkmanager_dns_mode = default

sed '/^dns=.*$/d' /etc/NetworkManager/NetworkManager.conf
