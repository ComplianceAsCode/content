#!/bin/bash

. $SHARED/partition.sh

PARTITION="/home"
mount_bind_partition "$PARTITION"
