#!/bin/bash
cat > /etc/crypto-policies/policies/modules/NO-SSHWEAKCIPHERS.pmod << EOF
cipher@SSH = -3DES-CBC -AES-128-CBC -AES-192-CBC -AES-256-CBC -CHACHA20-POLY1305
EOF
