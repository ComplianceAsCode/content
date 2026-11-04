#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# variables = var_password_hashing_algorithm_pam=sha512
# packages = libuser

# A crypt_style in an earlier section must not shadow the [defaults] value.
cat > /etc/libuser.conf <<EOF
[import]
login_defs = /etc/login.defs
crypt_style = md5

[defaults]
crypt_style = sha512
modules = files shadow
create_modules = files shadow
EOF
