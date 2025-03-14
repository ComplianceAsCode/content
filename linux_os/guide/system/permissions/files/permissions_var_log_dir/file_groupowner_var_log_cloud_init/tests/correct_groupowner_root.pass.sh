#!/bin/bash
# platform = Ubuntu 24.04

getent group "adm" &>/dev/null || groupadd adm
touch /var/log/cloud-init.log
touch /var/log/cloud-init.log1
chgrp root /var/log/cloud-init.log*
