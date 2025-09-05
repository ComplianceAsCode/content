#!/bin/bash
# platform = Ubuntu 24.04

getent group "gdm" &>/dev/null || groupadd gdm
mkdir -p /var/log/gdm
chgrp -R root /var/log/gdm

touch /var/log/gdm/testfile
chgrp nogroup /var/log/gdm/testfile
