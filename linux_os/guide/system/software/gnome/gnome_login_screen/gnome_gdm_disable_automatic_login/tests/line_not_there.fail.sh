#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

yum -y install gdm

sed -i "/^AutomaticLoginEnable=.*/d" /etc/gdm/custom.conf
