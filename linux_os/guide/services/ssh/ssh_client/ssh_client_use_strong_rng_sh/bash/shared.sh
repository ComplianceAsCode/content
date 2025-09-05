#!/bin/bash
# platform = Red Hat Enterprise Linux 8

# put line into the file
echo "export SSH_USE_STRONG_RNG=32" > /etc/profile.d/cc-ssh-strong-rng.sh

# remove eventual override in /etc/profile
sed -i '/^[[:space:]]*export[[:space:]]\+SSH_USE_STRONG_RNG=.*$/d' /etc/profile
