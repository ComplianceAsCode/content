#!/bin/bash
cat > /etc/crypto-policies/policies/modules/STIG.pmod << EOF
cipher@SSH=AES-256-GCM AES-256-CTR AES-128-GCM AES-128-CTR
mac@SSH=HMAC-SHA2-512 HMAC-SHA2-256
EOF
