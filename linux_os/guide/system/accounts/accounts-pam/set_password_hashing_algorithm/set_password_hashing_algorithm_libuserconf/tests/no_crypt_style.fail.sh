#!/bin/bash
# variables = var_password_hashing_algorithm_pam=sha512

cp libuser.conf /etc/
sed -i "/crypt_style/d" /etc/libuser.conf
