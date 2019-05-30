#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

. ../dconf_test_functions.sh

if ! rpm -q dconf; then
    yum -y install dconf
fi

if ! rpm -q gdm; then
    yum -y install gdm
fi

# remove all database files
remove_dconf_databases

sleep 3

add_dconf_setting "org/gnome/login-screen" "banner-message-enabled" "true" "gdm.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "gdm.d" "00-security-settings-lock"

add_dconf_setting "org/gnome/login-screen" "banner-message-enabled" "true" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "local.d" "00-security-settings-lock"
