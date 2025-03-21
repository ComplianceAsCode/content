#!/bin/bash
# platform = Ubuntu 24.04

touch /var/log/btmp
touch /var/log/btmp.1
touch /var/log/btmp-1
chgrp root /var/log/btmp*
touch /var/log/wtmp
touch /var/log/wtmp.1
touch /var/log/wtmp-1
chgrp root /var/log/wtmp*
