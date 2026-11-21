#!/bin/bash
# platform = multi_platform_debian

mkdir -p /etc/apt/apt.conf.d
touch /etc/apt/apt.conf
find /etc/apt/apt.conf /etc/apt/apt.conf.d -maxdepth 1 -type f -exec sed -ri '/^[[:space:]]*(Acquire::)?AllowInsecureRepositories[[:space:]]+/Id' {} + 2>/dev/null || true

# APT reads files in apt.conf.d with no extension or with the .conf extension.
echo 'Acquire::AllowInsecureRepositories "0";' > /etc/apt/apt.conf.d/99-cac-test.conf
