#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

. $SHARED/dconf_test_functions.sh

yum -y install dconf
clean_dconf_settings

add_dconf_setting "org/gnome/desktop/media-handling" "automount" "false" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/desktop/media-handling" "automount" "local.d" "00-security-settings"

