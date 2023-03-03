#!/bin/bash
# variables = var_accounts_password_warn_age_login_defs=7

WARN_AGE_VALUE=3
TEST_USER="cac_testuser"

# create valid testuser entry in /etc/shadow
useradd $TEST_USER
sed -E -i "s/($TEST_USER:)(.*)/\1\$6\$exIFis0tobKRcGBk\$b.UR.Z8h96FdxJ1bgA\/vhdnp0Lsm488swdILNguQX\/5qH5hdmClyYb5xk3TpELXWzr4JOiTlHfRkPsXSjMPjv0:19396:1:60:$WARN_AGE_VALUE:::/" /etc/shadow

# ensure existing users with a password defined also have the correct value defined
users_to_set=($(awk -v var=\"$WARN_AGE_VALUE\" -F: '(($6 < var || $6 == \"\") && $2 ~ /^\$/) {print $1}' /etc/shadow))
for user in ${users_to_set[@]};
do
  chage --warndays $WARN_AGE_VALUE $user
done
