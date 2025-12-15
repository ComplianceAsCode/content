#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: server directive in sourcedir .sources file

# Create main conf with sourcedir
cat > {{{ chrony_conf_path }}} << EOF
sourcedir /etc/chrony/sources.d
EOF

# Create sources.d directory and file
mkdir -p /etc/chrony/sources.d
echo "server 0.pool.ntp.org" > /etc/chrony/sources.d/ntp.sources
