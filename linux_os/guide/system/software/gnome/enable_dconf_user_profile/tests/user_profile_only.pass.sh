#!/bin/bash
# platform = Ubuntu 26.04

rm -f /etc/dconf/profile/gdm
mkdir -p /etc/dconf/profile
cat > /etc/dconf/profile/user <<EOF
user-db:user
system-db:local
EOF
