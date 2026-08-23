#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ubuntu
# check-import = stdout

{{{ find_command(find_parameters="-nouser", fail_message="Found unowned files or directories", find_type="\( -type f -o -type d \)") }}}
