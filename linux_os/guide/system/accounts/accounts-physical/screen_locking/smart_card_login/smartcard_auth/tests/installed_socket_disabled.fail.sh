#!/bin/bash
# packages = pcsc-lite pam_pkcs11 esc



systemctl disable pcscd.socket

. ./configure_pam_stack.sh
