#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_profiles
{{% if product in ['sle15', 'sle16'] %}}
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% else %}}
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "local.d" "00-security-settings"
{{% endif %}}
