#!/bin/bash
# platform = Ubuntu 24.04

getent group "adm" &>/dev/null || groupadd adm
touch /var/log/localmessages
touch /var/log/localmessages1
chgrp root /var/log/localmessages*
