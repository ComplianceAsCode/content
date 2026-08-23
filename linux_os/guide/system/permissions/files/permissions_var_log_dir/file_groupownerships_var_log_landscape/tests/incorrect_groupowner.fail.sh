#!/bin/bash
# platform = Ubuntu 24.04

groupadd landscape || true
mkdir -p /var/log/landscape
touch /var/log/landscape/testfile
chgrp nogroup /var/log/landscape/testfile
