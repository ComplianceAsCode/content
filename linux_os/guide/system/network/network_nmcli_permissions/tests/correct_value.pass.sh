#!/bin/bash
# packages = polkit

cat <<EOF > /etc/polkit-1/localauthority/20-org.d/test.pkla
[Disable General User Access to NetworkManager]
Identity=default
Action=org.freedesktop.NetworkManager.*
ResultAny=no
ResultInactive=no
ResultActive=auth_admin
EOF
