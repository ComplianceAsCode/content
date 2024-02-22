#!/bin/bash

. "$SHARED/accounts_common.sh"

run_foreach_noninteractive_shell_account "echo \$user > /home/\$user/\$user.txt; chmod -Rf 700 /home/\$user/.*; chmod -f o+r /home/\$user/\$user.txt"
