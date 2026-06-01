#!/bin/bash
# platform = multi_platform_sle,multi_platform_ubuntu
# packages = dconf,gdm
# variables = var_screensaver_lock_delay=5

. $SHARED/dconf_test_functions.sh

clean_dconf_settings

{{% if product in ['sle15', 'sle16'] %}}
add_dconf_setting "org/gnome/desktop/screensaver" "lock-delay" "uint32 5" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% else %}}
add_dconf_setting "org/gnome/desktop/screensaver" "lock-delay" "uint32 5" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/desktop/screensaver" "lock-delay" "local.d" "00-security-settings"
{{% endif %}}
