#!/bin/bash
# variables = var_password_hashing_algorithm_pam=sha512

cp libuser.conf /etc/
sed -i "s/crypt_style = sha512/crypt_style = md5/" /etc/libuser.conf
