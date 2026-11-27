#!/bin/bash
# platform = multi_platform_ubuntu

echo 'Dir::Etc::main "cac-site.conf";' > /etc/apt/apt.conf.d/01-cac-paths
echo 'Acquire::Check-Date "false";' > /etc/apt/cac-site.conf
