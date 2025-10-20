#!/bin/bash
cat > /etc/crypto-policies/policies/modules/NO-SSHWEAKCIPHERS.pmod << EOF
cipher@SSH = -3DES-CBC -AES-128-CBC -CHACHA20-POLY1305 -AES-256-EBC
EOF
