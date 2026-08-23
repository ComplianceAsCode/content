#!/bin/bash
# packages = gdm,dconf
# profiles = xccdf_org.ssgproject.content_profile_stig

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed
clean_dconf_settings

add_dconf_profiles
{{% if product in ['sle15', 'sle16'] %}}
add_dconf_setting "org/gnome/desktop/media-handling" "automount" "false" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/desktop/media-handling" "automount" "{{{ dconf_gdm_dir }}}" "00-security-settings"
{{% else %}}
add_dconf_setting "org/gnome/desktop/media-handling" "automount" "false" "local.d" "00-security-settings"
add_dconf_lock "org/gnome/desktop/media-handling" "automount" "local.d" "00-security-settings"
{{% endif %}}
