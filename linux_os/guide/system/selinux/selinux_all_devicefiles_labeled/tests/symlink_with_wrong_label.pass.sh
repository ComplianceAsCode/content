#!/bin/bash
#   selinux / restorecon does not work under podman
# skip_test_env = podman-based

ln -s /dev/cpu /dev/foo
restorecon -F /dev/foo
