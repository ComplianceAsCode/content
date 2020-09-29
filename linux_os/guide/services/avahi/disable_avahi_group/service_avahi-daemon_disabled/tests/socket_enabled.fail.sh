#!/bin/bash
#

yum -y install avahi

systemctl unmask avahi-daemon
systemctl disable avahi-daemon.service
systemctl enable avahi-daemon.socket
