#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/gdm
chown -R root /var/log/gdm

touch /var/log/gdm/testfile
chown root /var/log/gdm/testfile
