#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S

yum -y install avahi

systemctl stop avahi-daemon.service
systemctl disable avahi-daemon.service
systemctl mask avahi-daemon.service

systemctl stop avahi-daemon.socket
systemctl disable avahi-daemon.socket
