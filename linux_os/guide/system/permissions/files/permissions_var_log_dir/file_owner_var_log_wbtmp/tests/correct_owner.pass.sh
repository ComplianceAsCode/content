#!/bin/bash

touch /var/log/btmp
touch /var/log/btmp.1
touch /var/log/btmp-1
chown root /var/log/btmp*
touch /var/log/wtmp
touch /var/log/wtmp.1
touch /var/log/wtmp-1
chown root /var/log/wtmp*


