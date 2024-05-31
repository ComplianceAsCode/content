#!/bin/bash
# platform = multi_platform_ubuntu
# packages = gdm3
# variables = login_banner_text=default

source $SHARED/dconf_test_functions.sh
clean_dconf_settings
add_dconf_profiles

echo > /etc/gdm3/greeter.dconf-defaults

banner_default="Authorized uses only. All activity may be monitored and reported."
add_dconf_setting "org/gnome/login-screen" "banner-message-text" "'$banner_default'" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-text" "{{{ dconf_gdm_dir }}}" "00-security-settings-lock"

dconf update
