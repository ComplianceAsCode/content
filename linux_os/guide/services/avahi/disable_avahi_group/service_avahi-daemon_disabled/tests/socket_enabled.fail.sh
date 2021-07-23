#!/bin/bash
# packages = {{{- ssgts_package("avahi") -}}}
#

systemctl unmask avahi-daemon
systemctl disable avahi-daemon.service
systemctl enable avahi-daemon.socket
