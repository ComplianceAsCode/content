#!/bin/bash
# platform = multi_platform_debian
# remediation = none

rm -f /etc/apt/sources.list /etc/apt/sources.list.d/*

cat > /etc/apt/sources.list.d/debian.list << 'EOF'
deb http://deb.debian.org/debian bookworm main
deb http://security.debian.org/debian-security bookworm-security main
EOF
