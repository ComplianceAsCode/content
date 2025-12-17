#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: Multiple sourcedir declarations, server in second directory
SOURCES_DIR1="/etc/chrony/sources1.d"
SOURCES_DIR2="/etc/chrony/sources2.d"
rm -rf $SOURCES_DIR1
rm -rf $SOURCES_DIR2

# Create main conf with multiple sourcedir
cat > {{{ chrony_conf_path }}} << EOF
sourcedir $SOURCES_DIR1
sourcedir $SOURCES_DIR2
EOF

# Create first directory (empty)
mkdir -p $SOURCES_DIR1

# Create second directory with server
mkdir -p $SOURCES_DIR2
echo "server time.example.com" > $SOURCES_DIR2/custom.sources
