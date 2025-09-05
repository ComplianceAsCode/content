#!/bin/bash

echo 'password required pam_faillock.so' > /etc/pam.d/system-auth
echo local_users_only > /etc/security/faillock.conf
