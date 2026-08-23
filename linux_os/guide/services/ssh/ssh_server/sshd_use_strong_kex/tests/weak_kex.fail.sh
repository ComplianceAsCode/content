#!/bin/bash
# platform = multi_platform_all
# variables = sshd_strong_kex=curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

source include.sh
echo "KexAlgorithms diffie-hellman-group-exchange-sha1" >> "{{{ sshd_main_config_file }}}"
