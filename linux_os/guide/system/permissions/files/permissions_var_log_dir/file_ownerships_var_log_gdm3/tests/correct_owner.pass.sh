#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/gdm3
chown -R root /var/log/gdm3

touch /var/log/gdm3/testfile
chown root /var/log/gdm3/testfile
