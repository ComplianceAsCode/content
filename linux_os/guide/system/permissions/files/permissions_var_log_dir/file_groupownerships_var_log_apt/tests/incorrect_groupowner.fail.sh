#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/apt
touch /var/log/apt/testfile
chgrp nogroup /var/log/apt/testfile
