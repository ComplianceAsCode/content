#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S

yum -y install avahi

systemctl disable avahi-daemon.service
systemctl disable avahi-daemon.socket
systemctl mask avahi-daemon
