#!/bin/bash

if [ -f /usr/sbin/authconfig ]
then
    authconfig --disablefaillock --updateall
else
    authselect select sssd --force
fi
