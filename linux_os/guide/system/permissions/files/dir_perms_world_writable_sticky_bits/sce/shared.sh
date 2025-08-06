#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel
# check-import = stdout

{{{ find_directories(find_parameters="\( -perm -0002 -a ! -perm -1000 \)", fail_message="Found directories with writable sticky bits") }}}
