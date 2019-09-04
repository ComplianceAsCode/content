#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

. $SHARED/dconf_test_functions.sh

yum -y install dconf
clean_dconf_settings
add_dconf_setting "org/gnome/desktop/screensaver" "lock-enabled" "true" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/desktop/screensaver" "lock-enabled" "local.d" "00-security-settings"
