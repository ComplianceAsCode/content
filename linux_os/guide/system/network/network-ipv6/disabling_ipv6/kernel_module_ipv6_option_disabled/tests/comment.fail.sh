#!/bin/bash

rm -f /etc/modprobe.d/ipv6.conf
echo "# options ipv6 disable=0" > /etc/modprobe.d/ipv6.conf
