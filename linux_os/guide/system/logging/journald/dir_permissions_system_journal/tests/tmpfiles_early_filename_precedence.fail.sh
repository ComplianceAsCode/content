#!/bin/bash
# platform = multi_platform_ubuntu

# Precedence dimension: FILE NAME ordering.
#
# Configuration files are read from /etc/tmpfiles.d, /run/tmpfiles.d and
# /usr/lib/tmpfiles.d and are sorted by file name regardless of the directory
# they live in. Because z/Z entries adjust permissions of existing inodes, every
# matching entry is applied and the one applied last wins. A drop-in that sorts
# *before* the vendor systemd.conf is therefore overridden by it.
#
# Place a hardening drop-in under a name that sorts before "systemd.conf" so it
# loses against the vendor entry, together with a loose drop-in that sorts after
# it. The remediation writes "zzz-systemd-stig.conf", which sorts last and wins.
mkdir -p /etc/tmpfiles.d
cat > /etc/tmpfiles.d/00-journal-hardening.conf <<'EOF'
z /run/log/journal 2750 root systemd-journal - -
z /var/log/journal 2750 root systemd-journal - -
EOF

mkdir -p /run/log/journal /var/log/journal
chmod 2755 /run/log/journal /var/log/journal
