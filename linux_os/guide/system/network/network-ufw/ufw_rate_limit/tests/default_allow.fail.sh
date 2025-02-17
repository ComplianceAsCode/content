#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_debian
# packages = ufw

source common.sh

ufw default allow
ufw -f enable
