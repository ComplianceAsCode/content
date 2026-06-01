#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
{{% if product in ['sle15', 'sle16'] %}}
add_dconf_setting "org/gnome/desktop/screensaver" "#picture-uri" "string ''" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/desktop/screensaver" "picture-uri" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% else %}}
add_dconf_setting "org/gnome/desktop/screensaver" "#picture-uri" "string ''" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/desktop/screensaver" "picture-uri" "local.d" "00-security-settings"
{{% endif %}}
