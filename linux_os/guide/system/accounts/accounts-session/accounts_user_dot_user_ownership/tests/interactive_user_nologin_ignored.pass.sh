#!/bin/bash

. "$SHARED/accounts_common.sh"

run_foreach_noninteractive_shell_account "touch /home/\$user/.bashrc; chown 10005 /home/\$user/.bashrc"

