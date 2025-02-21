#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/sssd
chgrp -R root /var/log/sssd

touch /var/log/sssd/testfile
chgrp root /var/log/sssd/testfile
