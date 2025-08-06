#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel,Ubuntu 24.04
# check-import = stdout

{{{ find_files(find_parameters="-nouser", fail_message="Found unowned files") }}}
