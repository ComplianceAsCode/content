#!/bin/bash

. $SHARED/sysctl.sh

sysctl_set_kernel_setting_to kexec_load_disabled 0
