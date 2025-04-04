#!/bin/bash
# platform = Ubuntu 24.04

getent group "utmp" &>/dev/null || groupadd utmp
touch /var/log/lastlog
touch /var/log/lastlog.1
chgrp nogroup /var/log/lastlog*
