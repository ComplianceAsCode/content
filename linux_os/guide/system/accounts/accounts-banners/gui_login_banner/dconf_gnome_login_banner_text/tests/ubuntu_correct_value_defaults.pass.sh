#!/bin/bash
# platform = Ubuntu 22.04,Ubuntu 24.04
# packages = gdm3
# variables = dconf_login_banner_text=TestBanner,dconf_login_banner_contents=TestBanner

source $SHARED/dconf_test_functions.sh
clean_dconf_settings
add_dconf_profiles

banner="TestBanner"

cat >/etc/gdm3/greeter.dconf-defaults <<EOF
[org/gnome/login-screen]
banner-message-text='$banner'
EOF

dconf update
