#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

. $SHARED/dconf_test_functions.sh

yum -y install dconf
clean_dconf_settings
add_dconf_lock "org/gnome/desktop/screensaver" "idle-activation-enabled" "local.d" "00-security-settings"
