#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora
# packages = nfs-utils

systemctl start nfs-server
systemctl enable nfs-server
