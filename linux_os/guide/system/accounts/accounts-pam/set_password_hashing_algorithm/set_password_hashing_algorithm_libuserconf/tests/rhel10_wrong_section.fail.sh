#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# variables = var_password_hashing_algorithm_pam=sha512
# packages = libuser

# crypt_style is present but in the [userdefaults] section, not [defaults].
cat > /etc/libuser.conf <<EOF
[import]
login_defs = /etc/login.defs

[userdefaults]
crypt_style = sha512

[defaults]
modules = files shadow
create_modules = files shadow
EOF
