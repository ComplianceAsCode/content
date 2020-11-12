#!/bin/bash

echo "export SSH_USE_STRONG_RNG=32" > /etc/profile.d/cc-ssh-strong-rng.sh
echo "setenv SSH_USE_STRONG_RNG 32" > /etc/profile.d/cc-ssh-strong-rng.csh
