#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel,Ubuntu 24.04
# check-import = stdout

{{{ find_files(find_parameters="-perm -002", fail_message="Found world-writable files") }}}
