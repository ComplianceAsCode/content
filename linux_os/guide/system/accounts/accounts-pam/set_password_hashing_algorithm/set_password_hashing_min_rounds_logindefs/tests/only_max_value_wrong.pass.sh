#!/bin/bash

echo "SHA_CRYPT_MIN_ROUNDS 5000" > "/etc/login.defs"
echo "SHA_CRYPT_MAX_ROUNDS 4999" >> "/etc/login.defs"
