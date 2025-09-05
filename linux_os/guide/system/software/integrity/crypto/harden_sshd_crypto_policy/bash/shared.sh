# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8


cp="CRYPTO_POLICY='-oCiphers=aes128-ctr,aes256-ctr,aes128-cbc,aes256-cbc -oMACs=hmac-sha2-256,hmac-sha2-512 -oGSSAPIKeyExchange=no -oKexAlgorithms=diffie-hellman-group14-sha1,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521 -oHostKeyAlgorithms=ssh-rsa,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384 -oPubkeyAcceptedKeyTypes=ssh-rsa,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384'"
file=/etc/crypto-policies/local.d/opensshserver-ospp.config

#blank line at the begining to ease later readibility
echo '' > "$file"
echo "$cp" >> "$file"
update-crypto-policies
