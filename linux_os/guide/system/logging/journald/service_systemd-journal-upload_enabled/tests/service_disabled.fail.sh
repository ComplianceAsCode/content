#!/bin/bash
# packages = systemd-journal-remote

cat > /etc/systemd/journal-upload.conf << EOM
[Upload]
URL=http://example.com
EOM

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" stop 'systemd-journal-upload.service'
"$SYSTEMCTL_EXEC" disable 'systemd-journal-upload.service'
