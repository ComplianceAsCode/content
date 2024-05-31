#!/bin/bash
# platform = multi_platform_ubuntu
# packages = gdm3
# variables = login_banner_text=default

source $SHARED/dconf_test_functions.sh
clean_dconf_settings
add_dconf_profiles

conffile="/etc/gdm3/greeter.dconf-defaults"

sed -i '/banner-message-enable=/d;/banner-message-text=/d' ${conffile}
sed -i "/^\[org\/gnome\/login-screen\]/a""banner-message-text='Wrong banner'" ${conffile}

dconf update
