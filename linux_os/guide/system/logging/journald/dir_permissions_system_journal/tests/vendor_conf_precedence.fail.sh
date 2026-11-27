#!/bin/bash
# platform = multi_platform_ubuntu

# Precedence dimension: VENDOR configuration in /usr/lib/tmpfiles.d.
#
# systemd ships /usr/lib/tmpfiles.d/systemd.conf, which contains
#   z /run/log/journal 2755 root systemd-journal - -
#   z /var/log/journal 2755 root systemd-journal - -
#   z /var/log/journal/%m 2755 root systemd-journal - -
# so a stock system ends up with the too permissive mode 2755 as soon as
# systemd-tmpfiles runs. The vendor file must not be edited, the hardened
# entries have to be shipped in a drop-in that is applied after it.
#
# Reproduce the stock state and remove any hardening drop-in.
rm -f /etc/tmpfiles.d/zzz-systemd-stig.conf

mkdir -p /run/log/journal /var/log/journal
find /run/log/journal /var/log/journal -type d -exec chmod 2755 {} \;
