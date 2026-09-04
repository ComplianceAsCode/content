#!/bin/bash
# packages = chrony
# platform = Ubuntu 26.04

SOURCES_DIR="/etc/chrony/sources.d"

rm -rf /etc/chrony/conf.d
rm -rf "$SOURCES_DIR"

cat > {{{ chrony_conf_path }}} << EOF
sourcedir $SOURCES_DIR
EOF

mkdir -p "$SOURCES_DIR"
cat > "$SOURCES_DIR/ubuntu-ntp-pools.sources" << EOF
pool 1.ntp.ubuntu.com iburst maxsources 1 nts prefer
pool 2.ntp.ubuntu.com iburst maxsources 1 nts prefer
EOF
