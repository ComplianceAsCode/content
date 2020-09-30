#!/bin/bash


yum install -y pcsc-lite pam_pkcs11 esc

systemctl enable pcscd.socket

. ./configure_pam_stack.sh
