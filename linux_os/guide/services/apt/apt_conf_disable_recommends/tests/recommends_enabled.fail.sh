#!/bin/bash
# remediation = none

cat > /etc/apt/apt.conf.d/00-enable-recommends <<EOF
APT::Install-Recommends "1";
EOF
