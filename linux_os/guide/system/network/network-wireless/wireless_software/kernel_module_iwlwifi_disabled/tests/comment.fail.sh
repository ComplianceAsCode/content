#!/bin/bash

mkdir -p /etc/modprobe.d/
if [ -f /etc/modprobe.d/iwlwifi.conf ]; then
    sed -i '/install iwlwifi/d' /etc/modprobe.d/iwlwifi.conf   
fi
echo "# install iwlwifi /bin/true" > /etc/modprobe.d/iwlwifi.conf