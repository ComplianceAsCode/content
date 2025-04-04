#!/bin/bash
# platform = Ubuntu 24.04

getent group "adm" &>/dev/null || groupadd adm
touch /var/log/waagent.log
touch /var/log/waagent.log1
chgrp nogroup /var/log/waagent.log*
