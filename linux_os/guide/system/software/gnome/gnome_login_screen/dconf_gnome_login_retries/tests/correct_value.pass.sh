#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "allowed-failures" "3" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "allowed-failures" "{{{ dconf_gdm_dir }}}" "00-security-settings-lock"

dconf update
