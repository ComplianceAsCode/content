#!/bin/bash
# platform = multi_platform_ubuntu
# packages = gdm3
# variables = dconf_login_banner_text=TestBanner,dconf_login_banner_contents=TestBanner

source $SHARED/dconf_test_functions.sh
clean_dconf_settings
add_dconf_profiles

echo > "/etc/gdm3/greeter.dconf-defaults"

dconf update
