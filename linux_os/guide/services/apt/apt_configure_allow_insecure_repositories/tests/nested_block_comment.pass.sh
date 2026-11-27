#!/bin/bash
# platform = multi_platform_debian

mkdir -p /etc/apt/apt.conf.d
touch /etc/apt/apt.conf
find /etc/apt/apt.conf /etc/apt/apt.conf.d -maxdepth 1 -type f -exec sed -ri '/^[[:space:]]*(Acquire::)?AllowInsecureRepositories[[:space:]]+/Id' {} + 2>/dev/null || true

# A conflicting value inside a /* ... */ comment in the Acquire block is ignored.
printf '%s\n' 'Acquire {' '/*' '  AllowInsecureRepositories "1";' '*/' '  AllowInsecureRepositories "0";' '};' > /etc/apt/apt.conf.d/99-cis-repository-security
