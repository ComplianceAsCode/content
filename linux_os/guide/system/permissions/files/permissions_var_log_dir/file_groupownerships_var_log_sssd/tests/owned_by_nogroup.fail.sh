#!/bin/bash
# platform = Ubuntu 24.04

groupadd sssd || true

mkdir -p /var/log/sssd
chgrp -R root /var/log/sssd

touch /var/log/sssd/testfile
chgrp nogroup /var/log/sssd/testfile
