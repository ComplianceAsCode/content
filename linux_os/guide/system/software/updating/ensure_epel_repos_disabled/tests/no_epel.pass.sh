#!/bin/bash
# packages = yum

# Test: No EPEL repository exists (should pass)

# Clean up any pre-existing EPEL repository files
rm -f /etc/yum.repos.d/*epel*.repo

# Create a non-EPEL repository file to ensure the directory exists
cat > /etc/yum.repos.d/custom.repo << EOF
[custom-repo]
name=Custom Repository
enabled=1
baseurl=https://example.com/repo
gpgcheck=1
EOF
