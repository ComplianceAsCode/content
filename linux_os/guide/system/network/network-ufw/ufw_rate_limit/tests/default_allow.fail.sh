#!/bin/bash
# platform = multi_platform_ubuntu
# packages = ufw

source common.sh

ufw default allow
ufw -f enable
