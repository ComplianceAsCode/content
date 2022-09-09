#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

login_banner_text="Wrong Banner Text"
expanded=$(echo "$login_banner_text" | sed 's/(\\\\\x27)\*/\\\x27/g;s/(\\\x27)\*//g;s/(\\\\\x27)/tamere/g;s/(\^\(.*\)\$|.*$/\1/g;s/\[\\s\\n\][+*]/ /g;s/\\//g;s/(n)\*/\\n/g;s/\x27/\\\x27/g;')

{{% if 'ubuntu' not in product %}}
source $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed


clean_dconf_settings
add_dconf_setting "org/gnome/login-screen" "banner-message-text" "'${expanded}'" "{{{ dconf_gdm_dir }}}" "00-security-settings"
add_dconf_lock "org/gnome/login-screen" "banner-message-text" "{{{ dconf_gdm_dir }}}" "00-security-settings-lock"

{{% else %}}
    apt update
    apt install gdm3 -y
    conffile="/etc/gdm3/greeter.dconf-defaults"
    sed -i '/banner-message-enable=/d;/banner-message-text=/d' ${conffile}
    sed -i "/^\[org\/gnome\/login-screen\]/a""banner-message-text=$expanded" ${conffile}
{{% endif %}}

dconf update
