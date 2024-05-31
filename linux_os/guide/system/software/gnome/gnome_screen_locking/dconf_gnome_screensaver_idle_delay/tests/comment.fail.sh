#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_profiles
add_dconf_setting "org/gnome/desktop/session" "#idle-delay" "uint32 900" "local.d" "00-security-settings"
