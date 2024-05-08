#!/bin/bash
# platform = multi_platform_ubuntu
# packages = dconf,gdm

cat > /etc/gdm3/greeter.dconf-defaults <<EOF
[org/gnome/login-screen]
#banner-message-enable=true
EOF
