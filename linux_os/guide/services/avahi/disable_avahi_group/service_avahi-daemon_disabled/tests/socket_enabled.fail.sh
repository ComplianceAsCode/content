#!/bin/bash
# packages = avahi
#

systemctl unmask avahi-daemon.service
systemctl unmask avahi-daemon.socket
systemctl disable avahi-daemon.service
systemctl enable avahi-daemon.socket
