#!/bin/bash
# packages = avahi
#


systemctl stop avahi-daemon.service
systemctl disable avahi-daemon.service
systemctl mask avahi-daemon.service

systemctl stop avahi-daemon.socket
systemctl disable avahi-daemon.socket
