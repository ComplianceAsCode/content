#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# variables = var_password_hashing_algorithm_pam=sha512
# packages = libuser

# A commented-out crypt_style in [defaults] does not satisfy the requirement.
cat > /etc/libuser.conf <<EOF
[defaults]
# crypt_style = sha512
modules = files shadow
create_modules = files shadow
EOF
