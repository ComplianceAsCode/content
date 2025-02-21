#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/gdm3
chgrp -R root /var/log/gdm3

touch /var/log/gdm3/testfile
chgrp root /var/log/gdm3/testfile
