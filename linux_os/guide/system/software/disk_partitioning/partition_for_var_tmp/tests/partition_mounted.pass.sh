#!/bin/bash

. $SHARED/partition.sh

PARTITION="/var/tmp"
mount_bind_partition "$PARTITION"
