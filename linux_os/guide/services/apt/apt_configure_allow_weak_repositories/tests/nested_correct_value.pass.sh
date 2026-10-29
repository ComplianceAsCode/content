#!/bin/bash
# platform = multi_platform_ubuntu

mkdir -p /etc/apt/apt.conf.d
printf '%s\n' 'Acquire {' '  AllowWeakRepositories "0";' '};' > /etc/apt/apt.conf.d/99-cis-repository-security
