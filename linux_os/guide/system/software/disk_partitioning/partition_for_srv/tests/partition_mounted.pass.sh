#!/bin/bash

. $SHARED/partition.sh

PARTITION="/srv"
mount_bind_partition "$PARTITION"
