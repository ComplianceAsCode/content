#!/bin/bash

echo 'password required pam_faillock.so' > /etc/pam.d/system-auth
echo llocal_users_onlyy > /etc/security/faillock.conf
