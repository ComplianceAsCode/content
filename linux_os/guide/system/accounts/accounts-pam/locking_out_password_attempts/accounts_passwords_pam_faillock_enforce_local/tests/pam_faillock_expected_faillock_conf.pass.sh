#!/bin/bash

authselect enable-feature with-faillock
> /etc/security/faillock.conf
echo "local_users_only" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
