#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_setting "org/gnome/desktop/screensaver" "idle-activation-enabled" "true" \
                  "local.d" "00-security-settings"
add_dconf_lock "org/gnome/desktop/screensaver" "idle-activation-enabled" "local.d" \
               "00-security-settings-lock"
