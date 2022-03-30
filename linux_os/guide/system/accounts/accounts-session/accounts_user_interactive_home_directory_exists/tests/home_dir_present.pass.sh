#!/bin/bash

USER="cac_user"
useradd -m $USER

# This is to make sure that any possible user create in the test environment has also
# a home dir created on the system.
for user in $(awk -F':' '{ if ($3 >= {{{ uid_min }}} && $3 != 65534) print $1}' /etc/passwd); do
    mkhomedir_helper $user 0077;
done
