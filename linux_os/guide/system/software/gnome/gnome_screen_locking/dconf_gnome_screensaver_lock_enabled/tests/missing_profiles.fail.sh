#!/bin/bash
# platform = multi_platform_ubuntu
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings

add_dconf_setting "org/gnome/desktop/screensaver" "lock-enabled" "true" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/desktop/screensaver" "lock-enabled" "{{{ dconf_gdm_dir }}}" "00-security-settings"
