#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: Empty sourcedir but server in main conf - should pass
SOURCES_DIR="/etc/chrony/sources.d"
rm -rf /etc/chrony/conf.d
rm -rf $SOURCES_DIR

# Create main conf with server AND sourcedir
cat > {{{ chrony_conf_path }}} << EOF
server 0.pool.ntp.org
sourcedir $SOURCES_DIR
EOF

# Create empty sources.d directory
mkdir -p $SOURCES_DIR
