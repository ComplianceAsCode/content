#!/bin/bash
# platform = multi_platform_all
# remediation = none

{{{ bash_remove_interactive_users_from_passwd_by_uid() }}}

mkdir -p /root_home
useradd -m -d /root_home/testUser1 testUser1
