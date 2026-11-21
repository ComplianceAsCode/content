#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

USER="cac_user"
useradd -m $USER
mkdir -p /root/.cac-test
chown $USER /root/.cac-test
