#!/bin/bash

mkdir -p /etc/modprobe.d/
if [ -f /etc/modprobe.d/mac80211.conf ]; then
    sed -i '/install mac80211/d' /etc/modprobe.d/mac80211.conf   
fi
echo "# install mac80211 /bin/true" > /etc/modprobe.d/mac80211.conf