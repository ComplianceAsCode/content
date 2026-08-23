#!/bin/bash
# platform = multi_platform_ubuntu
# packages = dconf,gdm

source $SHARED/dconf_test_functions.sh

clean_dconf_settings

add_dconf_setting "org/gnome/login-screen" "banner-message-enable" "true" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "{{{ dconf_gdm_dir }}}" "00-security-settings"

dconf update
