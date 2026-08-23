#!/bin/bash
# platform = multi_platform_ubuntu
# packages = dconf,gdm

clean_dconf_settings

cat > /etc/gdm3/greeter.dconf-defaults <<EOF
[org/gnome/login-screen]
banner-message-enable=true
EOF

dconf update
