#!/bin/bash
# packages = systemd-journal-remote

cat > /etc/systemd/journal-upload.conf << EOM
[Upload]
URL=http://example.com
EOM

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask 'systemd-journal-upload.service'
"$SYSTEMCTL_EXEC" start 'systemd-journal-upload.service'
"$SYSTEMCTL_EXEC" enable 'systemd-journal-upload.service'
