#!/bin/bash

if [ -f /etc/modprobe.d/sctp.conf ]; then
    sed -i '/install sctp/d' /etc/modprobe.d/sctp.conf
fi
echo "# install sctp /bin/true" > /etc/modprobe.d/sctp.conf
