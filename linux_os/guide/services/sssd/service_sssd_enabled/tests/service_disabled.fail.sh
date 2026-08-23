#!/bin/bash
# packages = sssd

source common.sh

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" stop 'sssd.service'
"$SYSTEMCTL_EXEC" disable 'sssd.service'
