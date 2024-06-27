#!/bin/bash
# packages = authselect


if [ -f /usr/sbin/authconfig ]; then
    authconfig --disablefaillock --update
else
    authselect select sssd --force
    authselect disable-feature with-faillock
fi
