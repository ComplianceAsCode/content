#!/bin/bash

# for each noninteractive shell, create user account
# and eval ommands which are passed in as function arguments
function run_foreach_noninteractive_shell_account {
  for shell in "/sbin/nologin" \
               "/usr/sbin/nologin" \
               "/bin/false" \
               "/usr/bin/false"; do

    user=cac_user${shell//\//_}
    useradd -m -s $shell $user

    eval "$*"
  done
}
