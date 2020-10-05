#!/bin/bash

. $SHARED/sysctl.sh

sysctl_set_kernel_setting_to yama.ptrace_scope 0
