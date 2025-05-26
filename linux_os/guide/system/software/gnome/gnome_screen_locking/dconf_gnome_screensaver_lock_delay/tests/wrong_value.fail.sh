#!/bin/bash
# packages = dconf,gdm
# variables = var_screensaver_lock_delay=5

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_profiles
add_dconf_setting "org/gnome/desktop/screensaver" "lock-delay" "uint32 10" "local.d" "00-security-settings"

{{% if 'ubuntu' in product %}}
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "local.d" "00-security-settings"
{{% endif %}}
