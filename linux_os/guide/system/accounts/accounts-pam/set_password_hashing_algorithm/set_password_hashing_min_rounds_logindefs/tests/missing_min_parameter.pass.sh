#!/bin/bash
# variables = var_password_hashing_min_rounds_login_defs=5000

# Default values are 5000 if the parameters are not defined.
echo "SHA_CRYPT_MAX_ROUNDS 5000" > "/etc/login.defs"
