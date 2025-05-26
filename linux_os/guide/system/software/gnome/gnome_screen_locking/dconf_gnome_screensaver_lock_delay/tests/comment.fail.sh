#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_profiles
add_dconf_setting "org/gnome/desktop/screensaver" "#lock-delay" "uint32 5" "local.d" "00-security-settings"

{{% if 'ubuntu' in product %}}
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "local.d" "00-security-settings"
{{% endif %}}
