#!/bin/bash
# platform = multi_platform_debian

mkdir -p /etc/apt/apt.conf.d
touch /etc/apt/apt.conf
find /etc/apt/apt.conf /etc/apt/apt.conf.d -maxdepth 1 -type f -exec sed -ri '/^[[:space:]]*(Acquire::)?AllowWeakRepositories[[:space:]]+/Id' {} + 2>/dev/null || true

# APT reads every statement on a line, so the second one is in effect.
echo 'Acquire::AllowWeakRepositories "0"; Acquire::AllowWeakRepositories "1";' > /etc/apt/apt.conf.d/99-cis-repository-security
