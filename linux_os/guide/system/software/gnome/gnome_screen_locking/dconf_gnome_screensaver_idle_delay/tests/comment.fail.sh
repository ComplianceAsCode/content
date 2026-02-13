#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_profiles
{{% if product in ['sle15', 'sle16'] %}}
add_dconf_setting "org/gnome/desktop/session" "#idle-delay" "uint32 900" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% else %}}
add_dconf_setting "org/gnome/desktop/session" "#idle-delay" "uint32 900" "local.d" "00-security-settings"
{{% endif %}}

{{% if 'ubuntu' in product %}}
add_dconf_lock "org/gnome/desktop/session" "idle-delay" "local.d" "00-security-settings"
{{% elif product in ['sle15', 'sle16'] %}}
add_dconf_lock "org/gnome/desktop/session" "idle-delay" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% endif %}}
