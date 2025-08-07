#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel
# check-import = stdout

{{{ find_directories(find_parameters="-perm -0002 -uid +"~uid_min, fail_message="Found world-writable directories that are not owned by a system account") }}}
