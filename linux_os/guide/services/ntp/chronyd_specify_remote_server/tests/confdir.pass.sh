#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: server directive in confdir .conf file

# Create main conf with confdir
cat > {{{ chrony_conf_path }}} << EOF
confdir /etc/chrony/conf.d
EOF

# Create conf.d directory and file
mkdir -p /etc/chrony/conf.d
echo "pool 1.pool.ntp.org" > /etc/chrony/conf.d/ntp-servers.conf
