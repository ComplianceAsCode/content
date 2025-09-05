#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel
# check-import = stdout

{{{ find_files(find_parameters="-perm -4000", fail_message="Found SUID executables that are unauthorized", skip_rpm_owned_files=True) }}}
