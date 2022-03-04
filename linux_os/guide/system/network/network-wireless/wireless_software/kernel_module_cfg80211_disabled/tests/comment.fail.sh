#!/bin/bash

mkdir -p /etc/modprobe.d/
if [ -f /etc/modprobe.d/cfg80211.conf ]; then
    sed -i '/install cfg80211/d' /etc/modprobe.d/cfg80211.conf   
fi
echo "# install cfg80211 /bin/true" > /etc/modprobe.d/cfg80211.conf