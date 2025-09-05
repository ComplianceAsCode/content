#!/bin/bash
# packages = policycoreutils-python-utils
# platform = multi_platform_slmicro5

semanage fcontext -m -t faillog_t "/var/log/tallylog"
