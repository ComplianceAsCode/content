#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/landscape
touch /var/log/landscape/testfile
chgrp root /var/log/landscape/testfile
