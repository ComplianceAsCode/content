#!/bin/bash

. "$SHARED/accounts_common.sh"

run_foreach_noninteractive_shell_account "rm -rf /home/\$user"
