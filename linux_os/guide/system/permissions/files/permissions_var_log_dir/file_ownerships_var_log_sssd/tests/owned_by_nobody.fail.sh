#!/bin/bash
# platform = Ubuntu 24.04

useradd sssd || true

mkdir -p /var/log/sssd
chown -R root /var/log/sssd

touch /var/log/sssd/testfile
chown nobody /var/log/sssd/testfile
