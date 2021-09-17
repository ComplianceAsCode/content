#!/bin/bash

if [ -f /usr/sbin/authconfig ]
then
    authconfig --enablefaillock --updateall
else
    authselect select sssd with-faillock --force
fi
