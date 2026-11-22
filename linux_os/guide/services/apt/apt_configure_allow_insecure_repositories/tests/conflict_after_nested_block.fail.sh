#!/bin/bash
# platform = multi_platform_debian

mkdir -p /etc/apt/apt.conf.d
touch /etc/apt/apt.conf
find /etc/apt/apt.conf /etc/apt/apt.conf.d -maxdepth 1 -type f -exec sed -ri '/^[[:space:]]*(Acquire::)?AllowInsecureRepositories[[:space:]]+/Id' {} + 2>/dev/null || true

# A conflicting value after a nested block in the Acquire block is detected.
echo 'Acquire::AllowInsecureRepositories "0";' > /etc/apt/apt.conf.d/99-cis-repository-security
printf '%s\n' 'Acquire {' '  http { Timeout "30"; };' '  AllowInsecureRepositories "1";' '};' > /etc/apt/apt.conf.d/50-cac-test
