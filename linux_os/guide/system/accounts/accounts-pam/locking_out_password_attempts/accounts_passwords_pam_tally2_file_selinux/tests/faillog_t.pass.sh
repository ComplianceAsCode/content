#!/bin/bash
# packages = policycoreutils-python-utils
# platform = multi_platform_slmicro

semanage fcontext -m -t faillog_t "/var/log/tallylog"
