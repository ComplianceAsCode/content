#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
{{% if 'sle' in product %}}
add_dconf_settings "org/gnome/desktop/lockdown", "disable-lock-screen", "false", "dummy.d", "00-security-settings"
add_dconf_lock "org/gnome/desktop/lockdown", "disable-lock-screen", "dummy.d", "00-security-settings-lock"
{{% else %}}
add_dconf_setting "org/gnome/desktop/screensaver" "lock-enabled" "true" "dummy.d" "00-security-settings"
add_dconf_lock "org/gnome/desktop/screensaver" "lock-enabled" "dummy.d" "00-security-settings"
{{% endif %}}
