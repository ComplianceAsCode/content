#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_profiles
{{% if product in ['sle15', 'sle16'] %}}
add_dconf_setting "org/gnome/desktop/screensaver" "#lock-delay" "uint32 5" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% else %}}
add_dconf_setting "org/gnome/desktop/screensaver" "#lock-delay" "uint32 5" "local.d" "00-security-settings"
{{% endif %}}

{{% if 'ubuntu' in product %}}
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "local.d" "00-security-settings"
{{% elif product in ['sle15', 'sle16'] %}}
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% endif %}}
