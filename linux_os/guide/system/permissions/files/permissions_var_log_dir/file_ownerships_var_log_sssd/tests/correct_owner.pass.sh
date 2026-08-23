#!/bin/bash
# platform = Ubuntu 24.04

id sssd &>/dev/null || useradd sssd
mkdir -p /var/log/sssd
chown -R root /var/log/sssd

touch /var/log/sssd/testfile
chown sssd /var/log/sssd/testfile
