#!/bin/bash
#   selinux / restorecon does not work under podman
# skip_test_env = podman-based

touch /dev/foo
restorecon -F /dev/foo
