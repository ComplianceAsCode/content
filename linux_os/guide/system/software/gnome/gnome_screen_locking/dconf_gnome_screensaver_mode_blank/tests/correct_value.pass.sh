#!/bin/bash
# packages = dconf,gdm
# variables = inactivity_timeout_value=900

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_setting "org/gnome/desktop/screensaver" "picture-uri" "string ''" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/desktop/screensaver" "picture-uri" "local.d" "00-security-settings"
