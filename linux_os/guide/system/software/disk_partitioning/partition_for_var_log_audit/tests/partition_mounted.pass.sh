#!/bin/bash

. $SHARED/partition.sh

PARTITION="/var/log/audit"
mount_bind_partition "$PARTITION"
