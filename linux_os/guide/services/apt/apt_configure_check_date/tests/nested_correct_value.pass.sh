#!/bin/bash
# platform = multi_platform_ubuntu

mkdir -p /etc/apt/apt.conf.d
printf '%s\n' 'Acquire {' '  Check-Date "true";' '};' > /etc/apt/apt.conf.d/99-cis-repository-security
