#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: Multiple sourcedir declarations, server in second directory

# Create main conf with multiple sourcedir
cat > {{{ chrony_conf_path }}} << EOF
sourcedir /etc/chrony/sources1.d
sourcedir /etc/chrony/sources2.d
EOF

# Create first directory (empty)
mkdir -p /etc/chrony/sources1.d

# Create second directory with server
mkdir -p /etc/chrony/sources2.d
echo "server time.example.com" > /etc/chrony/sources2.d/custom.sources
