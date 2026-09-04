#!/bin/bash
# platform = multi_platform_ubuntu

# Precedence dimension: CONFIGURATION DIRECTORY.
#
# Configuration is read from /etc/tmpfiles.d, /run/tmpfiles.d and
# /usr/lib/tmpfiles.d, and the files of all three directories are sorted
# together by file name. A loose entry dropped into /run/tmpfiles.d under a name
# that sorts last is therefore applied after the hardened entry.
mkdir -p /run/tmpfiles.d
cat > /run/tmpfiles.d/zzzzz-runtime-override.conf <<'EOF'
z /run/log/journal 2777 root systemd-journal - -
z /var/log/journal 2777 root systemd-journal - -
EOF

mkdir -p /run/log/journal /var/log/journal
chmod 2777 /run/log/journal /var/log/journal
