#!/bin/bash
# platform = Ubuntu 24.04

mkdir -p /var/log/sssd
chown -R root /var/log/sssd

touch /var/log/sssd/testfile
chown root /var/log/sssd/testfile
