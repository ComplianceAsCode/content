#!/bin/bash
# platform = multi_platform_rhel
sed -i 's/use_authtok/remember/' /etc/pam.d/system-auth /etc/pam.d/password-auth
