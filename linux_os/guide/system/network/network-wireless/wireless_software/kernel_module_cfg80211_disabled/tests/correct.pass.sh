#!/bin/bash

mkdir -p /etc/modprobe.d/
echo "install cfg80211 /bin/true" > /etc/modprobe.d/cfg80211.conf