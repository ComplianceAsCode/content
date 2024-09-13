#!/bin/bash
# packages = sssd-common

rm /etc/sssd/sssd.conf
rm -rf /etc/sssd/conf.d/
# Only empty config without any section
touch /etc/sssd/sssd.conf
