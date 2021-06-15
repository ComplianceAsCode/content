#!/bin/bash
# platform = Red Hat Enterprise Linux 7

# Test targeted to RHEL 7.4
yum downgrade -y openssh-6.6.1p1 openssh-clients-6.6.1p1 openssh-server-6.6.1p1
