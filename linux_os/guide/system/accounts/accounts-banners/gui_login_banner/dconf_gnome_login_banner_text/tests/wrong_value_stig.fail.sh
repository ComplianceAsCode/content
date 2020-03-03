#!/bin/bash
# platform = Red Hat Enterprise Linux 7, Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_stig

source $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

login_banner_text="Wrong Banner Text"
expanded=$(echo "$login_banner_text" | sed 's/(\\\\\x27)\*/\\\x27/g;s/(\\\x27)\*//g;s/(\\\\\x27)/tamere/g;s/(\^\(.*\)\$|.*$/\1/g;s/\[\\s\\n\][+*]/ /g;s/\\//g;s/(n)\*/\\n/g;s/\x27/\\\x27/g;')

clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "banner-message-text" "'${expanded}'" "gdm.d" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-text" "gdm.d" "00-security-settings-lock"

dconf update
