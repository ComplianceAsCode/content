#!/bin/bash

. $SHARED/partition.sh

PARTITION="/boot"
mount_bind_partition "$PARTITION"
