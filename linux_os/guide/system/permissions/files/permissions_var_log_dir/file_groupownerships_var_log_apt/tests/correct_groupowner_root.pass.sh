#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/apt
touch /var/log/apt/testfile
chgrp root /var/log/apt/testfile
