#!/bin/bash
#
# Note: We cannot test negative scenario for /var as
# unmounting it would break the test env (rpm db is
# stored in /var).

. $SHARED/partition.sh

PARTITION="/var"
mount_bind_partition "$PARTITION"
