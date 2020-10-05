#!/bin/bash

. $SHARED/sysctl.sh

sysctl_set_kernel_setting_to kptr_restrict 0
