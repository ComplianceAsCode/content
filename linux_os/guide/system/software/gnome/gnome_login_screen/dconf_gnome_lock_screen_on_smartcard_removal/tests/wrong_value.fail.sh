#!/bin/bash

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
add_dconf_setting "org/gnome/settings-daemon/peripherals/smartcard" "removal-action" "'wrong_value'" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/settings-daemon/peripherals/smartcard" "removal-action" "local.d" "00-security-settings-lock"

dconf update
