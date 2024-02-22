#!/bin/bash

. "$SHARED/accounts_common.sh"

run_foreach_noninteractive_shell_account "echo \$user > /home/\$user/\$user.txt; chgrp 10005 /home/\$user/\$user.txt"
