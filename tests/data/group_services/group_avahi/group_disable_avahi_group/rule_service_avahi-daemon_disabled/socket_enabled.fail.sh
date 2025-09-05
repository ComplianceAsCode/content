#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S

yum -y install avahi

systemctl unmask avahi-daemon
systemctl disable avahi-daemon.service
systemctl enable avahi-daemon.socket
