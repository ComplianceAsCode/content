#!/bin/bash
# platform = multi_platform_ubuntu

mkdir -p /etc/apt/apt.conf.d
touch /etc/apt/apt.conf
find /etc/apt/apt.conf /etc/apt/apt.conf.d -maxdepth 1 -type f -exec sed -ri '/^[[:space:]]*(Acquire::)?AllowInsecureRepositories[[:space:]]+/Id' {} + 2>/dev/null || true
echo '# Acquire::AllowInsecureRepositories "1";' >> /etc/apt/apt.conf
