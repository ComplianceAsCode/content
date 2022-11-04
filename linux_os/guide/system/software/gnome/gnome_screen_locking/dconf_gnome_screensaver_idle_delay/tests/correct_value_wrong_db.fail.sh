#!/bin/bash
# packages = dconf,gdm
# variables = inactivity_timeout_value=900

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_setting "org/gnome/desktop/session" "idle-delay" "uint32 900" "dummy.d" "00-security-settings"
