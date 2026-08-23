#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

getent group "adm" &>/dev/null || groupadd adm
touch /var/log/waagent.log
touch /var/log/waagent.log1
chgrp root /var/log/waagent.log*
