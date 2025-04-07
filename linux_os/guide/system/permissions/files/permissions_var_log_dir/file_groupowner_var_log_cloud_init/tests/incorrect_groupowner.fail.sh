#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

getent group "adm" &>/dev/null || groupadd adm
touch /var/log/cloud-init.log
touch /var/log/cloud-init.log1
chgrp nogroup /var/log/cloud-init.log*
