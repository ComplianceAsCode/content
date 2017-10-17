#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

yum install -y pcsc-lite pam_pkcs11 esc

systemctl disable pcscd.socket

. ./configure_pam_stack.sh
