#!/bin/bash
# platform = multi_platform_debian
# remediation = none

mkdir -p /etc/apt/sources.list.d
rm -f /etc/apt/sources.list /etc/apt/sources.list.d/*
touch /etc/apt/sources.list
