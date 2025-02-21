#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/gdm
chgrp -R root /var/log/gdm

touch /var/log/gdm/testfile
chgrp root /var/log/gdm/testfile
