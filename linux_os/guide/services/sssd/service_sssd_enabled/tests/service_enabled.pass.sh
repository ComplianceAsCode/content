#!/bin/bash
# packages = sssd-common

source common.sh

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask 'sssd.service'
"$SYSTEMCTL_EXEC" start 'sssd.service'
"$SYSTEMCTL_EXEC" enable 'sssd.service'
