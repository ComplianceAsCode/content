#!/bin/bash
# platform = Ubuntu 24.04

getent group "landscape" &>/dev/null || groupadd landscape
mkdir -p /var/log/landscape
touch /var/log/landscape/testfile
chgrp landscape /var/log/landscape/testfile
