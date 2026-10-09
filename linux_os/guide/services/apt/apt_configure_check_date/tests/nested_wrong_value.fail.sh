#!/bin/bash
# platform = multi_platform_ubuntu

mkdir -p /etc/apt/apt.conf.d
printf '%s\n' 'Acquire {' '  Check-Date "false";' '};' > /etc/apt/apt.conf.d/70-cac-test
