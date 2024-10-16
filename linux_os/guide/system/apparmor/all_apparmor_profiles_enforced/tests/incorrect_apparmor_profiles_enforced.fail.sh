#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ubuntu
# packages = apparmor

#Replace apparmor definitions and force profiles into compliant mode
apparmor_parser -C -q -r  /etc/apparmor.d/ 
