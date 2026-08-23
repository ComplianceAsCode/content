#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_ubuntu

# Test: server directive in confdir .conf file
CONF_DIR="/etc/chrony/conf.d"
rm -rf $CONF_DIR
rm -rf /etc/chrony/sources.d

# Create main conf with confdir
cat > {{{ chrony_conf_path }}} << EOF
confdir $CONF_DIR
EOF

# Create conf.d directory and file
mkdir -p $CONF_DIR
echo "pool 1.pool.ntp.org" > $CONF_DIR/ntp-servers.conf
