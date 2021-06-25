#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

configfile=/etc/crypto-policies/back-ends/opensshserver.config

echo "CRYPTO_POLICY='-oCiphers=aes128-ctr,aes256-ctr,aes128-cbc,aes256-cbc -oMACs=hmac-sha2-256,hmac-sha2-512 -oGSSAPIKeyExchange=no -oKexAlgorithms=diffie-hellman-group14-sha1,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521 -oHostKeyAlgorithms=rsa-sha2-256,ecdsa-sha2-nistp256,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384,ecdsa-sha2-nistp384-cert-v01@openssh.com,rsa-sha2-512,ecdsa-sha2-nistp521,ecdsa-sha2-nistp521-cert-v01@openssh.com -oPubkeyAcceptedKeyTypes=ssh-rsa,ecdsa-sha2-nistp256,ecdsa-sha2-nistp38'" > "$configfile"
