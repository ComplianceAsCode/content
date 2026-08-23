#!/bin/bash
# platform = SUSE Linux Enterprise 15

mkdir -p /var/log/testme
touch /var/log/testme/wtmp
chmod 660 /var/log/testme/wtmp
