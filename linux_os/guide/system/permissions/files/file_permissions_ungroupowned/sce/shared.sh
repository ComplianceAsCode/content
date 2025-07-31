#!/usr/bin/env bash
# platform = multi_platform_rhel, Ubuntu 24.04
# check-import = stdout

{{{ find_files(find_parameters="-nogroup", fail_message="Found ungroupowned files") }}}
