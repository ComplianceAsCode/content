#!/bin/bash
# platform = multi_platform_ubuntu

# remove all pam-auth-update configs which update the
# primary password block and create a config with well defined
# high priority to ensure correct stacking of our module
grep -il "Password-Type: Primary" /usr/share/pam-configs/* | grep -v "/unix$" | xargs rm -f

cat << EOF > /usr/share/pam-configs/cac_test_echo
Name: Echo
Default: yes
Priority: 10000
Password-Type: Primary
Password:
        password optional pam_echo.so
Password-Initial:
        password optional pam_echo.so
EOF
