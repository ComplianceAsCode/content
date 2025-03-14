#!/bin/bash
# platform = Ubuntu 24.04

getent group "adm" &>/dev/null || groupadd adm
touch /var/log/secure
touch /var/log/secure1.1
touch /var/log/secure.1
touch /var/log/secure-1
chgrp root /var/log/secure*
