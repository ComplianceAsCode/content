#!/bin/bash
# platform = multi_platform_ubuntu

# Precedence dimension: FILE NAME ordering, drop-in sorting AFTER the drop-in
# written by the remediation.
#
# Because z/Z entries are applied to already existing inodes, systemd-tmpfiles
# applies every matching entry and the entry applied last wins. A drop-in that
# sorts after "zzz-systemd-stig.conf" would therefore be applied last and would
# reset the journal directories back to a too permissive mode. The remediation
# neutralizes conflicting journal entries in the other drop-ins.
mkdir -p /etc/tmpfiles.d
cat > /etc/tmpfiles.d/zzzz-late-override.conf <<'EOF'
z /run/log/journal 2755 root systemd-journal - -
z /var/log/journal 2755 root systemd-journal - -
EOF

mkdir -p /run/log/journal /var/log/journal
chmod 2755 /run/log/journal /var/log/journal
