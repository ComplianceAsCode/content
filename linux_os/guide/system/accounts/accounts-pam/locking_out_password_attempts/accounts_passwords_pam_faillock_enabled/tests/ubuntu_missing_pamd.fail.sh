#!/bin/bash
# platform = multi_platform_ubuntu
# packages = pam

sed '/pam_faillock.so/d' /etc/pam.d/common-auth
