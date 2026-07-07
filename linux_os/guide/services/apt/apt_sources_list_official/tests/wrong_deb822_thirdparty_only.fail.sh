#!/bin/bash
# platform = multi_platform_debian
# remediation = none

mkdir -p /etc/apt/sources.list.d
rm -f /etc/apt/sources.list /etc/apt/sources.list.d/*

cat > /etc/apt/sources.list.d/example.sources << 'EOF'
Types: deb
URIs: https://packages.example.com/debian
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/example.gpg
EOF
