#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ncp

source $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "banner-message-enable" "false" "gdm.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "gdm.d" "00-security-settings"

dconf update
