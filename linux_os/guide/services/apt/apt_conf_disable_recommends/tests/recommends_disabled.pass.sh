#!/bin/bash
# remediation = none

cat > /etc/apt/apt.conf.d/00-disable-recommends <<EOF
APT::Install-Recommends "0";
EOF
