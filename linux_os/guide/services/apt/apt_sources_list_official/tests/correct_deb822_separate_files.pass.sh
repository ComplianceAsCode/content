#!/bin/bash
# platform = Debian 12
# remediation = none

mkdir -p /etc/apt/sources.list.d
rm -f /etc/apt/sources.list /etc/apt/sources.list.d/*

cat > /etc/apt/sources.list.d/debian.sources << 'EOF'
Types: deb
URIs: http://deb.debian.org/debian
Suites: bookworm
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

cat > /etc/apt/sources.list.d/debian-security.sources << 'EOF'
Types: deb
URIs: http://deb.debian.org/debian-security
Suites: bookworm-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
