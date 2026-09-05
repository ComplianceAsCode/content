#!/bin/bash
# platform = Ubuntu 26.04

mkdir -p /etc/apt/apt.conf.d
printf '%s\n' 'Acquire {' '  AllowDowngradeToInsecureRepositories "0";' '};' > /etc/apt/apt.conf.d/99-cis-repository-security
