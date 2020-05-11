#!/bin/bash

echo "tmpfs /dev/shm tmpfs rw,seclabel,nodev,nosuid 0 0" >> /etc/fstab
