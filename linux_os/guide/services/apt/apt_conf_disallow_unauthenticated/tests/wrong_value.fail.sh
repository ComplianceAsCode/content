#!/bin/bash
# platforms = multi_platform_ubuntu
# remediation = none

sed '/AllowUnauthenticated/Id' -i /etc/apt/apt.conf /etc/apt/apt.conf.d/*

echo 'ATP::Get::AllowUnauthenticated "true";' >> /etc/apt/apt.conf
