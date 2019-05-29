#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

. ../../../../group_software/group_gnome/dconf_test_functions.sh

if ! rpm -q dconf; then
    yum -y install dconf
fi

if ! rpm -q gdm; then
    yum -y install gdm
fi

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "banner-message-enable" "false" "gdm.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "gdm.d" "00-security-settings"

dconf update
