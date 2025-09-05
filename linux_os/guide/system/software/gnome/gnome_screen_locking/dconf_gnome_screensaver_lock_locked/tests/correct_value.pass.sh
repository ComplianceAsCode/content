#!/bin/bash

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed
clean_dconf_settings
add_dconf_lock "org/gnome/desktop/screensaver" "lock-enabled" "local.d" "00-security-settings"
