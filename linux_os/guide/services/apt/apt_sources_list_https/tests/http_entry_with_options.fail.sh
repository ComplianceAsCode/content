#!/bin/bash
# platform = multi_platform_ubuntu

# An options block between deb and the URI must not hide the http:// entry.
cat > /etc/apt/sources.list <<'EOF'
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu resolute main
EOF
