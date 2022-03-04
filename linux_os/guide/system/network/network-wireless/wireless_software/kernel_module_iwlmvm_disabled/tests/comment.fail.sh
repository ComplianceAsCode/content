#!/bin/bash

mkdir -p /etc/modprobe.d/
if [ -f /etc/modprobe.d/iwlmvm.conf ]; then
    sed -i '/install iwlmvm/d' /etc/modprobe.d/iwlmvm.conf   
fi
echo "# install iwlmvm /bin/true" > /etc/modprobe.d/iwlmvm.conf