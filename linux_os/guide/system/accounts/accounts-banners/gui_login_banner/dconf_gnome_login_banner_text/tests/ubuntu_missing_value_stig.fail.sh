#!/bin/bash
# platform = multi_platform_ubuntu
# profiles = xccdf_org.ssgproject.content_profile_stig
# packages = gdm3

conffile="/etc/gdm3/greeter.dconf-defaults"
sed -i '/banner-message-enable=/d;/banner-message-text=/d' ${conffile}

dconf update
