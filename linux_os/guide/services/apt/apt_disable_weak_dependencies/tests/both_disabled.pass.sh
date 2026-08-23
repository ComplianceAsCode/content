#!/bin/bash
# platform = multi_platform_debian

find /etc/apt/apt.conf.d/ -type f -exec sed -i '/APT::Install-Recommends/Id;/APT::Install-Suggests/Id' {} \;

cat > /etc/apt/apt.conf.d/60-no-weak-dependencies << 'EOF'
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
