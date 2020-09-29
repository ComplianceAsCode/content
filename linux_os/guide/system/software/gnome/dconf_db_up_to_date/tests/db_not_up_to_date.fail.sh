#!/bin/bash

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "banner-message-enabled" "true" "gdm.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "gdm.d" "00-security-settings-lock"

add_dconf_setting "org/gnome/login-screen" "banner-message-enabled" "true" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "local.d" "00-security-settings-lock"

dconf update

# ensure that the modification happens a reasonable amount of time after running dconf update
sleep 5

# make static keyfiles newer than the database
add_dconf_setting "org/gnome/login-screen" "banner-message-enabled" "true" "gdm.d" "00-security-settings"
add_dconf_setting "org/gnome/login-screen" "banner-message-enabled" "true" "local.d" "00-security-settings"
