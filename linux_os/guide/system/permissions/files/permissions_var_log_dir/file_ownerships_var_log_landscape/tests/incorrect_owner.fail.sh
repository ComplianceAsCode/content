#!/bin/bash
# platform = Ubuntu 24.04

useradd landscape || true
mkdir -p /var/log/landscape
touch /var/log/landscape/testfile
chown nobody /var/log/landscape/testfile
