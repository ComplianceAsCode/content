#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
{{% if product in ['sle15', 'sle16'] %}}
add_dconf_lock "# org/gnome/desktop/session" "idle-delay" "{{{ dconf_gdm_dir }}}" "00-security-settings-lock"
{{% else %}}
add_dconf_lock "# org/gnome/desktop/session" "idle-delay" "local.d" "00-security-settings-lock"
{{% endif %}}
dconf update
