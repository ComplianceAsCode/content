#!/bin/bash
# packages = dconf,gdm

{{% set dconf_db = "distro.d" %}}
{{% if product not in ("fedora", "rhel9") %}}
{{% set dconf_db = "gdm.d" %}}
{{% endif %}}

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

# remove all database files
remove_dconf_databases

# ensure that the modification happens a reasonable amount of time after running dconf update
sleep 5

add_dconf_setting "org/gnome/login-screen" "banner-message-enabled" "true" "{{{ dconf_db }}}" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "{{{ dconf_db }}}" "00-security-settings-lock"

add_dconf_setting "org/gnome/login-screen" "banner-message-enabled" "true" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-enable" "local.d" "00-security-settings-lock"
