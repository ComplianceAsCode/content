#!/bin/bash
# platforms = multi_platform_ubuntu

sed '/AllowUnauthenticated/Id' -i /etc/apt/apt.conf /etc/apt/apt.conf.d/*

echo 'ATP::Get::AllowUnauthenticated "false";' >> /etc/apt/apt.conf.d/99-test
