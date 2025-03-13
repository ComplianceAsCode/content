#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

touch /var/log/secure
touch /var/log/secure1.1
touch /var/log/secure.1
touch /var/log/secure-1
chgrp nogroup /var/log/secure*
