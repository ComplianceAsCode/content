#!/bin/bash
# remediation = none

touch /etc/sssd/sssd.conf
sed -i "s/\[certmap.*//g" /etc/sssd/sssd.conf
