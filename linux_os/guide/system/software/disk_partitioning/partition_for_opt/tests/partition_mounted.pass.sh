#!/bin/bash

. $SHARED/partition.sh

PARTITION="/opt"
mount_bind_partition "$PARTITION"
