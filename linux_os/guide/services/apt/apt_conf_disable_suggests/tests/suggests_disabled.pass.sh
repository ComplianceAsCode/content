#!/bin/bash

cat > /etc/apt/apt.conf.d/00-disable-suggests <<EOF
APT::Install-Suggests "0";
EOF
