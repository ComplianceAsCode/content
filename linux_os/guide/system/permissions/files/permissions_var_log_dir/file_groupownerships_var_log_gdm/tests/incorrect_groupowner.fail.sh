#!/bin/bash
# platform = Ubuntu 24.04

groupadd gdm || true

mkdir -p /var/log/gdm
chgrp -R root /var/log/gdm

touch /var/log/gdm/testfile
chgrp nogroup /var/log/gdm/testfile
