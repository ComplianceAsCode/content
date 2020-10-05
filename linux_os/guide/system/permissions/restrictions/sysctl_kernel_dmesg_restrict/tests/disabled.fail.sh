#!/bin/bash
#

. $SHARED/sysctl.sh

sysctl_set_kernel_setting_to dmesg_restrict 0
