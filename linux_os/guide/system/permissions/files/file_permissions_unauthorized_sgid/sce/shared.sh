#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel
# check-import = stdout

{{{ find_files(find_parameters="-perm -2000", fail_message="Found SGID executables that are unauthorized", skip_rpm_owned_files=True) }}}
