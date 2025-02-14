#!/bin/bash

touch /var/log/wtmp
chown syslog /var/log/wtmp

touch /var/log/btmp
chown syslog /var/log/btmp
