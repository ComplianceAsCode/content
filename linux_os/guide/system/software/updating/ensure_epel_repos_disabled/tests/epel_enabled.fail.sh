#!/bin/bash
# packages = yum

# Test: EPEL repository exists and is enabled (should fail)

# Clean up any pre-existing EPEL repository files
rm -f /etc/yum.repos.d/*epel*.repo

cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 9 - \$basearch
enabled=1
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-9&arch=\$basearch&infra=\$infra&content=\$contentdir
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
EOF
