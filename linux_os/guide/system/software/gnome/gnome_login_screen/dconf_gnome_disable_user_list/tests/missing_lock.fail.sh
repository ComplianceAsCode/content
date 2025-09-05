#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "disable-user-list" "true" "{{{ dconf_gdm_dir }}}" "00-security-settings"

dconf update
