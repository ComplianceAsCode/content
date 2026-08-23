#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
{{% if product in ['sle15', 'sle16'] %}}
add_dconf_setting "org/gnome/desktop/screensaver" "idle-activation-enabled" "true" \
                  "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% else %}}
add_dconf_setting "org/gnome/desktop/screensaver" "idle-activation-enabled" "true" \
                  "local.d" "00-security-settings"
{{% endif %}}
