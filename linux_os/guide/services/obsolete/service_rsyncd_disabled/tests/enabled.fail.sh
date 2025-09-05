#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Oracle Linux 8,multi_platform_fedora,multi_platform_rhv
# packages = rsync-daemon

systemctl start rsyncd
systemctl enable rsyncd
