#!/bin/bash
# platform = multi_platform_ubuntu

# Precedence dimension: correctly ordered drop-in (positive case).
#
# A drop-in that sorts after the vendor systemd.conf and repeats the vendor line
# types and paths wins, because for z/Z entries every matching entry is applied
# and the entry applied last takes effect. Non-recursive "z" entries are applied
# after recursive "Z" entries, which is why the plain "z" lines are required in
# addition to the recursive ones.
mkdir -p /etc/tmpfiles.d
cat > /etc/tmpfiles.d/zzz-systemd-stig.conf <<'EOF'
z /run/log/journal ~2750 root systemd-journal - -
Z /run/log/journal ~2750 root systemd-journal - -
z /run/log/journal/%m ~2750 root systemd-journal - -
z /var/log/journal ~2750 root systemd-journal - -
Z /var/log/journal ~2750 root systemd-journal - -
z /var/log/journal/%m ~2750 root systemd-journal - -
EOF

mkdir -p /run/log/journal /var/log/journal
chmod 2755 /run/log/journal /var/log/journal
systemd-tmpfiles --create
