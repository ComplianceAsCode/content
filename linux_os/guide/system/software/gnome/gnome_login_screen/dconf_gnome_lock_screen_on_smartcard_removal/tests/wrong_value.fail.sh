#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
{{% if product in ['opensuse16', 'sle15', 'sle16'] %}}
add_dconf_setting "org/gnome/settings-daemon/peripherals/smartcard" "removal-action" "'none'" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/settings-daemon/peripherals/smartcard" "removal-action" "{{{ dconf_gdm_dir }}}" "00-security-settings-lock"
{{% else %}}
# this test is required because the removal-action parameter requires single quoted value which the templated test does not include
add_dconf_setting "org/gnome/settings-daemon/peripherals/smartcard" "removal-action" "'none'" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/settings-daemon/peripherals/smartcard" "removal-action" "local.d" "00-security-settings-lock"
{{% endif %}}

dconf update
