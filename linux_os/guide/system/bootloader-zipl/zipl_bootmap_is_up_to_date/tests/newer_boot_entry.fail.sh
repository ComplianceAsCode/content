#!/bin/bash
# platform = Red Hat Enterprise Linux 8
# remediation = none

touch /etc/zipl.conf
touch /boot/loader/entries/*.conf # Update current existing entries
touch /boot/loader/entries/zipl-entry-1.conf
touch /boot/bootmap
sleep 2
touch /boot/loader/entries/zipl-entry-2.conf
