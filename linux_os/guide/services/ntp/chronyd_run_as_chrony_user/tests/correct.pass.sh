#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle
# packages = chrony


echo 'OPTIONS="-u chrony"' > /etc/sysconfig/chronyd
