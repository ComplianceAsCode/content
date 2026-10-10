#!/bin/bash
# platform = multi_platform_opensuse,multi_platform_sle,multi_platform_ubuntu
# packages = dconf,gdm
# variables = var_screensaver_lock_delay=5

. $SHARED/dconf_test_functions.sh

clean_dconf_settings

add_dconf_profiles
{{% if product in ['opensuse16', 'sle15', 'sle16'] %}}
add_dconf_setting "org/gnome/desktop/screensaver" "lock-delay" "uint32 5" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% else %}}
add_dconf_setting "org/gnome/desktop/screensaver" "lock-delay" "uint32 5" "local.d" "00-security-settings"
{{% endif %}}
