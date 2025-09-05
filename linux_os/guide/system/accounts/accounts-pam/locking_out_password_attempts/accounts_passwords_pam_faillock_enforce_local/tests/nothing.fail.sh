#!/bin/bash

echo 'password required pam_faillock.so' > /etc/pam.d/system-auth
echo > /etc/security/faillock.conf
