#!/bin/bash
# platform = Ubuntu 24.04

getent group "adm" &>/dev/null || groupadd adm
touch /var/log/syslog
chgrp adm /var/log/syslog
