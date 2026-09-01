#!/bin/bash
# remediation = none

cat > /etc/apt/apt.conf.d/00-enable-suggests <<EOF
APT::Install-Suggests "1";
EOF
