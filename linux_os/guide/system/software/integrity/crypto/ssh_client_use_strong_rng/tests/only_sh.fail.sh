#!/bin/bash

echo "export SSH_USE_STRONG_RNG=32" > /etc/profile.d/cc-ssh-strong-rng.sh
rm -f /etc/profile.d/cc-ssh-strong-rng.csh
