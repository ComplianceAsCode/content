#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_lock "org/gnome/desktop/screensaver" "lock-enabled" "dummy.d" "00-security-settings"
