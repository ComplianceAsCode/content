#!/bin/bash
# variables = var_password_hashing_min_rounds_login_defs=5000

echo "SHA_CRYPT_MIN_ROUNDS 4999" > "/etc/login.defs"
echo "SHA_CRYPT_MAX_ROUNDS 5000" >> "/etc/login.defs"
