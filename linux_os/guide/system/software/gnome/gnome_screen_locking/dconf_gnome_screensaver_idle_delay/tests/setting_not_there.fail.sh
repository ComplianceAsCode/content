#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_profiles

{{% if 'ubuntu' in product %}}
add_dconf_lock "org/gnome/desktop/screensaver" "idle-delay" "local.d" "00-security-settings"
{{% endif %}}
