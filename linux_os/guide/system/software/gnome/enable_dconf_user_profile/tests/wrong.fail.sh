#!/bin/bash
# platform = multi_platform_ubuntu

cat > /etc/dconf/profile/gdm <<EOF
user-db:user
system-db:local
EOF

cat > /etc/dconf/profile/user <<EOF
user-db:user
system-db:gdm
EOF
