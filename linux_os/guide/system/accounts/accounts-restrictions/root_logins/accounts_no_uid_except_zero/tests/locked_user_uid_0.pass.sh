#!/bin/bash
# platform = multi_platform_all

useradd --non-unique --uid 0 rootlocked
# configure password, otherwise user is locked
echo "rootlocked:password" | chpasswd
passwd -l rootlocked
