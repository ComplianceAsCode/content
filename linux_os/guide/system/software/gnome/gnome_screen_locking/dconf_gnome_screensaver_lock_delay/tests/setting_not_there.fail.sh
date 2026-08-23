#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

add_dconf_profiles
clean_dconf_settings

{{% if 'ubuntu' in product %}}
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "local.d" "00-security-settings"
{{% elif product in ['sle15', 'sle16'] %}}
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% endif %}}
