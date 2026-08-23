#!/bin/bash
#
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

SSH_CONF="/etc/sysconfig/sshd"

sed -i "/^\s*CRYPTO_POLICY.*$/d" $SSH_CONF
echo "CRYPTO_POLICY=" >> $SSH_CONF
