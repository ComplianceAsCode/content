#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: Empty sourcedir but server in main conf - should pass

# Create main conf with server AND sourcedir
cat > {{{ chrony_conf_path }}} << EOF
server 0.pool.ntp.org
sourcedir /etc/chrony/sources.d
EOF

# Create empty sources.d directory
mkdir -p /etc/chrony/sources.d
