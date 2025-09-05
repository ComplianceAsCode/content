#!/bin/bash
#
# remediation = none

. $SHARED/partition.sh

umount_partition "/var/log/audit"
