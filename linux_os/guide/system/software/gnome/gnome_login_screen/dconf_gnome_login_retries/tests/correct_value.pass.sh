#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "allowed-failures" "3" "gdm.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "allowed-failures" "gdm.d" "00-security-settings-lock"

dconf update
