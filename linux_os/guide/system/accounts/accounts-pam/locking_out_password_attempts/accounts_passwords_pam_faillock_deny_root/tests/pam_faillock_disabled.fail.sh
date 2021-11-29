#!/bin/bash

if [ -f /usr/sbin/authconfig ]; then
    authconfig --disablefaillock --update
else
    authselect disable-feature with-faillock
fi
