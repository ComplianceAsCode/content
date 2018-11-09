#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_standard

SSH_CONF="/etc/sysconfig/sshd"

sed -i "/^\s*CRYPTO_POLICY.*$/d" $SSH_CONF
echo "# CRYPTO_POLICY=" >> $SSH_CONF
