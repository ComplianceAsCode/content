#!/bin/bash

. $SHARED/partition.sh

PARTITION="/tmp"
mount_bind_partition "$PARTITION"
