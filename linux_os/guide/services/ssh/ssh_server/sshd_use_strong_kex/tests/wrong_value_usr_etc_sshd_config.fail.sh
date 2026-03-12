#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = sshd_strong_kex=curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256
source include.sh

echo "KexAlgorithms diffie-hellman-group-exchange-sha1" >> /usr/etc/ssh/sshd_config
