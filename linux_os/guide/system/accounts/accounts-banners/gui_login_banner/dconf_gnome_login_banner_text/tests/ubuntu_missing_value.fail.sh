#!/bin/bash
# platform = multi_platform_ubuntu
# packages = gdm3

source $SHARED/dconf_test_functions.sh
clean_dconf_settings
add_dconf_profiles
echo > "/etc/gdm3/greeter.dconf-defaults"

dconf update
