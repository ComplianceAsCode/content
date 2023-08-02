#!/bin/bash
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# variables = sshd_approved_macs=hmac-sha2-512,hmac-sha2-256,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

configfile=/etc/crypto-policies/back-ends/opensshserver.config

echo "" > "$configfile"
