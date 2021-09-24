#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ol,multi_platform_fedora,multi_platform_rhv

sed -i 's/gpgcheck\s*=.*/gpgcheck=1/g' /etc/yum.repos.d/*
