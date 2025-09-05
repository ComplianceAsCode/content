#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

yum install -y pcsc-lite pam_pkcs11 esc

systemctl disable pcscd.socket
systemctl disable pcscd.service

. ./configure_pam_stack.sh
