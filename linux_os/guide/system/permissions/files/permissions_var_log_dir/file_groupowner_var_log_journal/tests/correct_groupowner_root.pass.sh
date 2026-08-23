#!/bin/bash
# platform = Ubuntu 24.04

getent group "systemd-journal" &>/dev/null || groupadd systemd-journal
chown -R root /var/log

mkdir -p /var/log/journal/
touch /var/log/journal/test.journal
touch /var/log/journal/test.journal~
chgrp root /var/log/journal/test.journal
chgrp root /var/log/journal/test.journal~

