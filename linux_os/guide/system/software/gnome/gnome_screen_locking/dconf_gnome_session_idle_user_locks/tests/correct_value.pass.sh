#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_lock "org/gnome/desktop/session" "idle-delay" "local.d" "00-security-settings-lock"

dconf update
