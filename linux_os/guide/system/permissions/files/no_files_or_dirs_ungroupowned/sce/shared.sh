#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel,Ubuntu 24.04
# check-import = stdout

{{{ find_command(find_parameters="-nogroup", fail_message="Found ungroupowned files or directories", exclude_directories="sysroot", find_type="\( -type f -o -type d \)") }}}
