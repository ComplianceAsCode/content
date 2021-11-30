#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora
# packages = nfs-utils

systemctl stop nfs-server
systemctl disable nfs-server
systemctl mask nfs-server
