#!/bin/bash
# platform = multi_platform_debian

mkdir -p /etc/apt/apt.conf.d
touch /etc/apt/apt.conf
find /etc/apt/apt.conf /etc/apt/apt.conf.d -maxdepth 1 -type f -exec sed -ri '/^[[:space:]]*(Acquire::)?AllowDowngradeToInsecureRepositories[[:space:]]+/Id' {} + 2>/dev/null || true

# APT ignores files in apt.conf.d whose names start with a dot.
echo 'Acquire::AllowDowngradeToInsecureRepositories "0";' > /etc/apt/apt.conf.d/.99-cac-test.conf
