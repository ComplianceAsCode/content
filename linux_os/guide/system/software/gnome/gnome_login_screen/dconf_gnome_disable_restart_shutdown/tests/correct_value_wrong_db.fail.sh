#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "disable-restart-buttons" "true" "dummy.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "disable-restart-buttons" "dummy.d" "00-security-settings-lock"

dconf update
