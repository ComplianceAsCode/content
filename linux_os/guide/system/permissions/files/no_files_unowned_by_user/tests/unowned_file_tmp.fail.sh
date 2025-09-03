#!/bin/bash
# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ubuntu
# remediation = none

mount tmpfs /tmp -t tmpfs

touch /tmp/test
chown 9999:9999 /tmp/test
