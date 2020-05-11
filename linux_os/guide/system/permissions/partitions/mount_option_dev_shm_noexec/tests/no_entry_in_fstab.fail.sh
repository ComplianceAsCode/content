#!/bin/bash

# make sure there is no entry for /dev/shm
sed -i '/\/dev\/shm/d' /etc/fstab
