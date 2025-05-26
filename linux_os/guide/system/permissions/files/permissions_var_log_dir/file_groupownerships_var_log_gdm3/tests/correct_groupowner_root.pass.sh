#!/bin/bash
# platform = Ubuntu 24.04

getent group "gdm" &>/dev/null || groupadd gdm
getent group "gdm3" &>/dev/null || groupadd gdm3
mkdir -p /var/log/gdm3
chgrp -R root /var/log/gdm3

touch /var/log/gdm3/testfile
chgrp root /var/log/gdm3/testfile
