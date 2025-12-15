#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: Commented sourcedir should be ignored - should fail

# Create main conf with commented sourcedir
cat > {{{ chrony_conf_path }}} << EOF
# sourcedir /etc/chrony/sources.d
EOF

# Create sources.d directory with server (should be ignored)
mkdir -p /etc/chrony/sources.d
echo "server 0.pool.ntp.org" > /etc/chrony/sources.d/ntp.sources
