#!/bin/bash

echo "export SSH_USE_STRONG_RNG=32" > /etc/profile.d/cc-ssh-strong-rng.sh
echo "export SSH_USE_STRONG_RNG=8" >> /etc/profile.d/cc-ssh-strong-rng.sh
