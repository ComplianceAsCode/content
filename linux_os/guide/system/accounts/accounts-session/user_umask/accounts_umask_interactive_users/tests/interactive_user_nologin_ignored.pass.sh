#!/bin/bash

. "$SHARED/accounts_common.sh"

run_foreach_noninteractive_shell_account "echo 'umask 022' >> /home/\$user/.bashrc"
