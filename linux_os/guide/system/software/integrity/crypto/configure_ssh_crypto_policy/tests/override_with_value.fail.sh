#!/bin/bash
#
# platform = Red Hat Enterprise Linux 8

SSH_CONF="/etc/sysconfig/sshd"

sed -i "/^\s*CRYPTO_POLICY.*$/d" $SSH_CONF
echo "CRYPTO_POLICY=LEGACY" >> $SSH_CONF
