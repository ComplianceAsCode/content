#!/bin/bash

touch /etc/sssd/sssd.conf
sed -i "s/\[certmap.*//g" /etc/sssd/sssd.conf
