#!/bin/bash
# packages = avahi
#


systemctl unmask avahi-daemon
systemctl disable avahi-daemon.service
systemctl enable avahi-daemon.socket
