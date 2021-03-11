#!/bin/bash

if [ -f /etc/modprobe.d/dccp.conf ]; then
    sed -i '/install dccp/d' /etc/modprobe.d/dccp.conf
fi
echo "# install dccp /bin/true" > /etc/modprobe.d/dccp.conf
