#!/bin/bash
# platform = multi_platform_ubuntu

# Parse the URI after an optional deb options block.
cat > /etc/apt/sources.list <<'EOF'
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu resolute main
EOF
