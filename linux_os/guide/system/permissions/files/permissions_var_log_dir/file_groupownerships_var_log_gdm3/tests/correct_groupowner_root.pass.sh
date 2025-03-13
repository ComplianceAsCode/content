#!/bin/bash
# platform = Ubuntu 24.04

groupadd gdm || true
groupadd gdm3 || true

mkdir -p /var/log/gdm3
chgrp -R root /var/log/gdm3

touch /var/log/gdm3/testfile
chgrp root /var/log/gdm3/testfile
