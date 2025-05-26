#!/bin/bash

touch /var/log/wtmp.s
chmod u+rw-x,g+rw-x,o+r-wx /var/log/wtmp.1
touch /var/log/wtmp-1
chmod u+rw-x,g+rw-x,o+r-wx /var/log/wtmp-1
touch /var/log/btmp.1
chmod u+rw-x,g+rw-x,o+r-wx /var/log/btmp.1
touch /var/log/btmp-1
chmod u+rw-x,g+rw-x,o+r-wx /var/log/btmp-1

