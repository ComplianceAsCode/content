#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: server directive in sourcedir .sources file
SOURCES_DIR="/etc/chrony/sources.d"
rm -rf /etc/chrony/conf.d
rm -rf $SOURCES_DIR

# Create main conf with sourcedir
cat > {{{ chrony_conf_path }}} << EOF
sourcedir $SOURCES_DIR
EOF

# Create sources.d directory and file
mkdir -p $SOURCES_DIR
echo "server 0.pool.ntp.org" > /etc/chrony/sources.d/ntp.sources
