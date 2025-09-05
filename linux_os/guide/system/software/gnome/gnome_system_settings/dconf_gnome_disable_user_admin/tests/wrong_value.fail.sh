#!/bin/bash

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
add_dconf_setting "org/gnome/desktop/lockdown" "user-administration-disabled" "false" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/desktop/lockdown" "user-administration-disabled" "local.d" "00-security-settings-lock"

dconf update
