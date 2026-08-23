#!/bin/bash

. $SHARED/partition.sh

PARTITION="/var/log"
mount_bind_partition "$PARTITION"
