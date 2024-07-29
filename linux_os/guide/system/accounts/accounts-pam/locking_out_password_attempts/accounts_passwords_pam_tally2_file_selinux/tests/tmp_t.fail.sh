#!/bin/bash
# packages = policycoreutils-python-utils
# platform = multi_platform_slmicro5

semanage fcontext -m -t tmp_t "/var/log/tallylog"
restorecon -R -v "/var/log/tallylog"
