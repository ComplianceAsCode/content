#!/bin/bash
# platform = multi_platform_ubuntu
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed
clean_dconf_settings

add_dconf_setting "org/gnome/settings-daemon/plugins/media-keys" "logout" "['']" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/settings-daemon/plugins/media-keys" "logout" "local.d" "00-security-settings"

dconf update
