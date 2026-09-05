#!/bin/bash
# platform = multi_platform_ubuntu

mkdir -p /etc/apt/apt.conf.d
touch /etc/apt/apt.conf
find /etc/apt/apt.conf /etc/apt/apt.conf.d -maxdepth 1 -type f -exec sed -ri '/^[[:space:]]*Acquire::AllowDowngradeToInsecureRepositories[[:space:]]+/Id' {} + 2>/dev/null || true

# APT option names are case insensitive and values may be unquoted.
echo 'acquire::allowdowngradetoinsecurerepositories 1;' >> /etc/apt/apt.conf.d/70-cac-test
