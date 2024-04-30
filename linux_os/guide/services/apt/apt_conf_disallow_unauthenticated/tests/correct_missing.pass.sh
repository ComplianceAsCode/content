#!/bin/bash
# platforms = multi_platform_ubuntu

sed '/AllowUnauthenticated/Id' -i /etc/apt/apt.conf /etc/apt/apt.conf.d/*
exit 0
