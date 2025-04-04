#!/bin/bash
# platform = Ubuntu 24.04

getent group "sssd" &>/dev/null || groupadd sssd
mkdir -p /var/log/sssd
chgrp -R root /var/log/sssd

touch /var/log/sssd/testfile
chgrp sssd /var/log/sssd/testfile
