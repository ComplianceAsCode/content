#!/bin/bash
# platform = multi_platform_ubuntu
# packages = pam

echo 'auth	requisite                       pam_faillock.so preauth' >> /etc/pam.d/common-auth
