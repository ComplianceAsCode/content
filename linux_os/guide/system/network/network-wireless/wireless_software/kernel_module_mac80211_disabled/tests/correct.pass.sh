#!/bin/bash

mkdir -p /etc/modprobe.d/
echo "install mac80211 /bin/true" > /etc/modprobe.d/mac80211.conf