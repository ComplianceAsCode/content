#!/bin/bash
#
# Note: We cannot test negative scenario for /usr as
# unmounting it would break the test env (ssh).

. $SHARED/partition.sh

PARTITION="/usr"
mount_bind_partition "$PARTITION"
