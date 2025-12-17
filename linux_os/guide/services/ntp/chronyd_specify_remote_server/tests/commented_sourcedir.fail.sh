#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: Commented sourcedir should be ignored - should fail
SOURCES_DIR="/etc/chrony/sources.d"
rm -rf /etc/chrony/conf.d
rm -rf $SOURCES_DIR

# Create main conf with commented sourcedir

cat > {{{ chrony_conf_path }}} << EOF
# sourcedir $SOURCES_DIR
EOF

# Create sources.d directory with server (should be ignored)
mkdir -p $SOURCES_DIR
echo "server 0.pool.ntp.org" > $SOURCES_DIR/ntp.sources
