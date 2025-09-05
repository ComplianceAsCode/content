#!/bin/bash
# packages = pcsc-lite pam_pkcs11 esc



systemctl enable pcscd.socket

. ./configure_pam_stack.sh
