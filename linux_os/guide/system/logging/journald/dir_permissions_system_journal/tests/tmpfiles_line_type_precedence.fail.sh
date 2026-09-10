#!/bin/bash
# platform = multi_platform_ubuntu

# Precedence dimension: LINE TYPE.
#
# systemd ships /usr/lib/tmpfiles.d/systemd.conf with a non-recursive
# "z /run/log/journal 2755" entry. For z/Z lines systemd-tmpfiles applies every
# matching entry instead of de-duplicating them, and non-recursive "z" lines are
# applied after recursive "Z" lines. A drop-in that only carries recursive "Z"
# lines is therefore overridden by the vendor "z" entry and the directories stay
# at 2755. The remediation must emit matching "z" lines as well.
#
# Re-create the vendor situation and leave a drop-in that only uses "Z".
mkdir -p /etc/tmpfiles.d
cat > /etc/tmpfiles.d/zzz-systemd-stig.conf <<'EOF'
Z /run/log/journal ~2750 root systemd-journal - -
Z /var/log/journal ~2750 root systemd-journal - -
EOF

mkdir -p /run/log/journal /var/log/journal
chmod 2755 /run/log/journal /var/log/journal
